# merge-comments

Automatically resolves conflicts in PO (and possibly other) files after git-merge

installation:

 1. ensure 'merge-comments.pl' is executable
    chmod a+x merge-comments.pl
   
 2. put 'merge-comments.pl' to your $PATH
    cp merge-comments.pl /usr/local/bin

 3. create it's temporary directory:
    mkdir ~/.merge-comments.pl

usage:

  1. do git-merge what issues a conflict
  2. run merge-comments.pl <conflicted-file> [<comment-regexp>]

This will find all conflicts in the file and test if replacing
'theirs' changes with 'yours' looses only spaces or comments (that is
lines what matches <comment-regexp>).

When all replaces of a conflict contains only comments, the conflict
will be resolved to 'mine' side.

All unresolved conflicts will be reported to STDERR.  You may want to
resolve them manually, for example with emacs' smerge-mode.

The default <comment-regexp> is '^\s*#'.
