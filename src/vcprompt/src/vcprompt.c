/*
 * Copyright (C) 2009, 2010, Gregory P. Ward and contributors.
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#include "common.h"
#include "cvs.h"
#include "git.h"
#include "hg.h"
#include "svn.h"
/*
#include "bzr.h"
*/

#define DEFAULT_FORMAT "[%n:%b%m%u] "

int parse_args(int argc, char** argv, options_t* options)
{
    int opt;
    while ((opt = getopt(argc, argv, "hf:d")) != -1) {
        switch (opt) {
            case 'f':
                options->format = strdup(optarg);
                ASSERT_NOOM(options->format);
                break;
            case 'd':
                options->debug = 1;
                break;
            case 'h':
            default:
                printf("usage: %s [-h] [-d] [-f FORMAT]\n", argv[0]);
                printf("FORMAT (default=\"%s\") may contain:\n%s",
                DEFAULT_FORMAT,
                " %b  show branch\n"
                " %r  show revision\n"
                " %u  show unknown\n"
                " %m  show modified\n"
                " %n  show VC name\n"
                " %%  show '%'\n"
                "\n"
                "If a percent sign is followed by text in a pair brackets\n"
                "('[xxx]') a default can be specified.\n"
                );
                printf("Environment Variables:\n"
                " VCPROMPT_FORMAT\n"
                );
                return 1;
        }
    }
    return 0;
}

static size_t read_default_format(const char* format, size_t i, char** out)
{
    size_t start = i;
    size_t length = 0;
    while (format[i] && format[i] != ']')
        i++, length++;
    if (format[i])
        i++;
    *out = malloc(length + 1);
    strncpy(*out, format + start, length);
    return i;
}

void parse_format(options_t* options)
{
    size_t i;

    options->show_branch = 0;
    options->show_unknown = 0;
    options->show_modified = 0;

    char* format = options->format;
    char* new_format = malloc(strlen(format) + 1);
    char* fmtp = new_format;
    char* next_default = NULL;
    size_t len = strlen(format);
    for (i = 0; i < len; i++) {
        if (format[i] == '%') {
            *fmtp++ = format[i++];
test:       switch (format[i]) {
                case '\0':              /* at end of string: ignore */
                    break;
                case '[':               /* default section */
                    i = read_default_format(format, i + 1, &next_default);
                    goto test;          /* consumed default, try again */
                case 'b':
                    options->show_branch = 1;
                    options->default_branch = next_default;
                    next_default = NULL;
                    goto end_of_loop;
                case 'r':
                    options->show_revision = 1;
                    options->default_revision = next_default;
                    next_default = NULL;
                    goto end_of_loop;
                case 'u':
                    options->show_unknown = 1;
                    goto end_of_loop;
                case 'm':
                    options->show_modified = 1;
                    goto end_of_loop;
                case 'n':               /* name of VC system */
                case '%':
                    goto end_of_loop;
                default:
                    fprintf(stderr,
                            "error: invalid format string: %%%c\n",
                            format[i]);
                    break;
            }
        }
        next_default = NULL;
end_of_loop:
        *fmtp++ = format[i];
    }

    *fmtp = '\0';
    free(options->format);
    options->format = new_format;
}

void print_result(vccontext_t* context, options_t* options, result_t* result)
{
    size_t i;
    char* format = options->format;
    size_t len = strlen(format);

    for (i = 0; i < len; i++) {
        if (format[i] == '%') {
            i++;
            switch (format[i]) {
                case '0':               /* end of string */
                case '%':               /* escaped % */
                    putc('%', stdout);
                    break;
                case 'b':
                    if (result->branch != NULL)
                        fputs(result->branch, stdout);
                    break;
                case 'r':
                    if (result->revision != NULL)
                        fputs(result->revision, stdout);
                    break;
                case 'u':
                    if (result->unknown)
                        putc('?', stdout);
                    break;
                case 'm':
                    if (result->modified)
                        putc('+', stdout);
                    break;
                case 'n':
                    fputs(context->name, stdout);
                    break;
                default:                /* %x printed as x */
                    putc(format[i], stdout);
            }
        }
        else {
            putc(format[i], stdout);
        }
    }
}

vccontext_t* probe_all(vccontext_t** contexts, int num_contexts)
{
    int idx;
    for (idx = 0; idx < num_contexts; idx++) {
        vccontext_t* ctx = contexts[idx];
        if (ctx->probe(ctx)) {
            return ctx;
        }
    }
    return NULL;
}

/* walk up the directory tree until the probes work or we hit / */
vccontext_t* probe_parents(vccontext_t** contexts, int num_contexts)
{
    vccontext_t* context;
    struct stat rootdir;
    struct stat curdir;

    debug("no context claimed current dir: walking up the tree");
    stat("/", &rootdir);
    while (1) {
        context = probe_all(contexts, num_contexts);
        if (context != NULL) {
            debug("found a context");
            return context;
        }

        stat(".", &curdir);
        int isroot = (rootdir.st_dev == curdir.st_dev &&
                      rootdir.st_ino == curdir.st_ino);
        if (isroot || (-1 == chdir(".."))) {
            return NULL;
        }
    }
}

int main(int argc, char** argv)
{
    char* format = getenv("VCPROMPT_FORMAT");
    if (format == NULL)
        format = DEFAULT_FORMAT;

    result_t* result = NULL;
    options_t *options = new_options(format);
    if (!options)
        return 1;

    /* might abort early in case the helpscreen is shown */
    if (parse_args(argc, argv, options)) {
        free_options(options);
        return 1;
    }

    parse_format(options);
    set_options(options);

    vccontext_t* contexts[] = {
        get_cvs_context(options),
        get_git_context(options),
        get_hg_context(options),
        get_svn_context(options),
    };
    int num_contexts = sizeof(contexts) / sizeof(vccontext_t*);

    vccontext_t* context = NULL;

    /* Starting in the current dir, walk up the directory tree until
       someone claims that this is a working copy. */
    context = probe_parents(contexts, num_contexts);

    /* Nobody claimed it: bail now without printing anything. */
    if (context == NULL)
        goto close_and_cleanup;

    /* Analyze the working copy metadata and print the result. */
    result = context->get_info(context);
    if (result != NULL) {
        print_result(context, options, result);
        if (options->debug)
            putc('\n', stdout);
    }

close_and_cleanup:
    free_result(result);
    free_options(options);
    return 0;
}
