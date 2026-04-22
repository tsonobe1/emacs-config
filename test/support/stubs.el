;;; stubs.el --- Minimal package stubs for config smoke tests -*- lexical-binding: t; -*-

(require 'cl-lib)

(eval-and-compile
  (defun config-test--use-package-sections (args)
    "Collect use-package ARGS into an alist keyed by keyword."
    (let (sections current)
      (dolist (arg args)
        (if (keywordp arg)
            (setq current arg)
          (push arg (alist-get current sections nil nil #'eq))))
      (dolist (cell sections)
        (setcdr cell (nreverse (cdr cell))))
      sections))

  (defun config-test--hook-variable (hook)
    "Return the actual hook variable symbol for HOOK."
    (let ((name (symbol-name hook)))
      (intern (if (string-suffix-p "-hook" name)
                  name
                (concat name "-hook")))))

  (defun config-test--expand-custom-forms (forms)
    "Convert :custom FORMS into `customize-set-variable' calls."
    (cl-loop for form in forms
             if (and (consp form) (symbolp (car form)) (cdr form))
             collect `(customize-set-variable ',(car form) ,(cadr form))))

  (defun config-test--expand-hook-spec (spec)
    "Convert a :hook SPEC into one or more `add-hook' forms."
    (cond
     ((and (consp spec) (symbolp (car spec)) (symbolp (cdr spec)))
      (list `(add-hook ',(config-test--hook-variable (car spec)) #',(cdr spec))))
     ((listp spec)
      (cl-mapcan #'config-test--expand-hook-spec spec))
     (t nil)))

  (defun config-test--expand-hook-forms (forms)
    "Convert all :hook FORMS into `add-hook' calls."
    (cl-mapcan #'config-test--expand-hook-spec forms)))

(defmacro use-package (name &rest args)
  "Evaluate the small subset of `use-package' used by this config."
  (declare (indent defun))
  (let* ((sections (config-test--use-package-sections args))
         (init-forms (alist-get :init sections nil nil #'eq))
         (config-forms (alist-get :config sections nil nil #'eq))
         (custom-forms (alist-get :custom sections nil nil #'eq))
         (hook-forms (alist-get :hook sections nil nil #'eq)))
    `(progn
       (require ',name nil t)
       ,@(config-test--expand-custom-forms custom-forms)
       ,@(config-test--expand-hook-forms hook-forms)
       ,@init-forms
       ,@config-forms)))

(provide 'use-package)

(defmacro flycheck-define-checker (&rest _args)
  "Ignore flycheck checker definitions during smoke tests."
  nil)

(defvar flycheck-checkers nil)
(defvar org-ai-api-key nil)
(defvar neo-buffer-name "*NeoTree*")

(defun org-roam-node-read ()
  'config-test-node)

(defun org-roam-node-id (_node)
  "config-test-node-id")

(defun org-roam-node-title (_node)
  "Config Test Node")

(dolist (fn '(which-key-mode
              doom-themes-neotree-config
              doom-themes-org-config
              doom-modeline-mode
              marginalia-mode
              marginalia-cycle
              vertico-mode
              org-roam-db-autosync-mode
              org-roam-ui-mode
              org-ai-mode
              org-ai-global-mode
              org-ai-install-yasnippets
              org-download-enable
              neotree-toggle
              flycheck-mode
              org-hugo-export-to-md))
  (defalias fn (lambda (&rest _args) nil)))

(dolist (feature '(all-the-icons
                   amx
                   compat
                   consult
                   dockerfile-mode
                   doom-modeline
                   doom-themes
                   embark
                   embark-consult
                   flycheck
                   gnuplot
                   marginalia
                   markdown-mode
                   neotree
                   ob-mermaid
                   orderless
                   org-ai
                   org-download
                   org-roam
                   ox-hugo
                   vertico
                   which-key
                   yaml-mode))
  (provide feature))

(provide 'stubs)

;;; stubs.el ends here
