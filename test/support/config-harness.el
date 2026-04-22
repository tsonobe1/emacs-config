;;; config-harness.el --- Smoke-test loader for the current Emacs config -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'org)
(require 'ob-tangle)
(require 'stubs)

(defconst config-test-repo-root
  (expand-file-name "../.." (file-name-directory (or load-file-name buffer-file-name))))

(defvar config-test--loaded nil)
(defvar config-test--temp-user-emacs-directory nil)
(defvar config-test--tangled-file nil)

(defun config-test-path (&rest segments)
  "Join SEGMENTS under the repository root."
  (let ((path config-test-repo-root))
    (dolist (segment segments)
      (setq path (expand-file-name segment path)))
    path))

(defun config-test-file-contents (path)
  "Return the full contents of PATH as a string."
  (with-temp-buffer
    (insert-file-contents path)
    (buffer-string)))

(defun config-test--tangle-config-copy ()
  "Tangle the current org config into the isolated temp directory."
  (setq config-test--tangled-file
        (expand-file-name "config/myinit.el" config-test--temp-user-emacs-directory))
  (make-directory (file-name-directory config-test--tangled-file) t)
  (org-babel-tangle-file (config-test-path "config" "myinit.org")
                         config-test--tangled-file
                         (rx string-start
                             (or "emacs-lisp" "elisp")
                             string-end))
  config-test--tangled-file)

(defun config-test-load ()
  "Load `config/myinit.org' once inside an isolated test harness."
  (unless config-test--loaded
    (setq config-test--temp-user-emacs-directory
          (make-temp-file "emacs-config-smoke-" t))
    (let ((user-emacs-directory config-test--temp-user-emacs-directory)
          (package-user-dir
           (expand-file-name "elpa" config-test--temp-user-emacs-directory))
          (default-directory config-test-repo-root))
      (require 'package)
      (config-test--tangle-config-copy)
      (let ((real-file-exists-p (symbol-function 'file-exists-p)))
        (cl-letf (((symbol-function 'package-install)
                   (lambda (&rest _args) t))
                  ((symbol-function 'package-refresh-contents)
                   (lambda (&rest _args) t))
                  ((symbol-function 'package-installed-p)
                   (lambda (&rest _args) t))
                  ((symbol-function 'url-retrieve-synchronously)
                   (lambda (&rest _args)
                     (error "network access is disabled in smoke tests")))
                  ((symbol-function 'load-theme)
                   (lambda (&rest _args) t))
                  ((symbol-function 'global-display-line-numbers-mode)
                   (lambda (&rest _args) t))
                  ((symbol-function 'set-frame-parameter)
                   (lambda (&rest _args) t))
                  ((symbol-function 'tool-bar-mode)
                   (lambda (&rest _args) t))
                  ((symbol-function 'file-exists-p)
                   (lambda (filename)
                     (if (string-match-p "config/secrets\\.el\\'" (expand-file-name filename))
                         nil
                       (funcall real-file-exists-p filename)))))
        (load-file config-test--tangled-file)
          (setq config-test--loaded t))))))

(provide 'config-harness)

;;; config-harness.el ends here
