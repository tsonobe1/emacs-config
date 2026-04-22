;;; tangle-myinit.el --- Tangle config/myinit.org into config/myinit.el -*- lexical-binding: t; -*-

(require 'org)
(require 'ob-tangle)

(let* ((script-dir (file-name-directory (or load-file-name buffer-file-name)))
       (repo-root (expand-file-name ".." script-dir))
       (org-file (expand-file-name "config/myinit.org" repo-root))
       (el-file (expand-file-name "config/myinit.el" repo-root))
       (org-confirm-babel-evaluate nil))
  (unless (file-exists-p org-file)
    (error "Org source not found: %s" org-file))
  (message "Tangling %s -> %s" org-file el-file)
  (org-babel-tangle-file org-file el-file "emacs-lisp")
  (message "Updated %s" el-file))
