;;; config-smoke.el --- Smoke tests for the current Emacs config -*- lexical-binding: t; -*-

(add-to-list 'load-path
             (expand-file-name "support"
                               (file-name-directory (or load-file-name buffer-file-name))))

(require 'ert)
(require 'config-harness)

(config-test-load)

(defun config-test--hook-contains-p (hook function)
  "Return non-nil when HOOK contains FUNCTION."
  (member function (symbol-value hook)))

(ert-deftest config-smoke/init-loads-org-source ()
  (with-temp-buffer
    (insert-file-contents (config-test-path "init.el"))
    (should (re-search-forward "org-babel-load-file" nil t))
    (should (re-search-forward "config/myinit.org" nil t))))

(ert-deftest config-smoke/loads-current-myinit ()
  (should config-test--loaded))

(ert-deftest config-smoke/harness-loads-tangled-copy ()
  (should (string-prefix-p config-test--temp-user-emacs-directory
                           config-test--tangled-file))
  (should (file-exists-p config-test--tangled-file))
  (should-not (string= (expand-file-name "config/myinit.el" config-test-repo-root)
                       config-test--tangled-file)))

(ert-deftest config-smoke/tracked-myinit-el-stays-in-sync ()
  (should (string=
           (config-test-file-contents config-test--tangled-file)
           (config-test-file-contents (config-test-path "config" "myinit.el")))))

(ert-deftest config-smoke/org-bindings-are-preserved ()
  (should (eq (lookup-key global-map (kbd "C-c c")) 'org-capture))
  (should (eq (lookup-key global-map (kbd "C-c a")) 'org-agenda))
  (should (eq (lookup-key global-map (kbd "C-c d")) 'my/remove-blank-lines))
  (should (eq (lookup-key global-map (kbd "<f8>")) 'neotree-toggle)))

(ert-deftest config-smoke/org-workflow-values-are-preserved ()
  (should (equal org-todo-keywords
                 '((sequence "TODO(t)" "WAIT(w)" "SAMEDAY(s)" "|"
                             "DONE(d)" "CANCEL(c)"))))
  (should (eq org-log-done 'time))
  (should (equal org-agenda-files '("~/.emacs.d/inbox.org"))))

(ert-deftest config-smoke/macos-paths-are-preserved ()
  (should (equal org-roam-directory (file-truename "~/.emacs.d/org-roam")))
  (should (equal org-roam-db-location "~/.emacs.d/org-roam/org-roam.db"))
  (should (equal org-babel-python-command "/Users/tsonobe/.emacs.d/env/bin/python"))
  (should (equal flycheck-textlint-config "~/.emacs.d/.textlintrc.json")))

(ert-deftest config-smoke/key-hooks-are-registered ()
  (should (config-test--hook-contains-p 'gfm-mode-hook 'flycheck-mode))
  (should (config-test--hook-contains-p 'markdown-mode-hook 'flycheck-mode))
  (should (config-test--hook-contains-p 'org-mode-hook 'flycheck-mode))
  (should (config-test--hook-contains-p 'org-mode-hook 'org-ai-mode))
  (should (config-test--hook-contains-p 'org-mode-hook 'org-download-enable)))

(ert-deftest config-smoke/completion-defaults-are-preserved ()
  (should (equal completion-styles '(orderless basic)))
  (should (equal completion-category-overrides
                 '((file (styles basic partial-completion))))))

(ert-deftest config-smoke/package-bootstrap-defaults-are-preserved ()
  (should (equal package-archives
                 '(("melpa" . "https://melpa.org/packages/")
                   ("gnu" . "https://elpa.gnu.org/packages/"))))
  (should (eq package-enable-at-startup nil))
  (should (eq use-package-always-ensure t))
  (should (equal my-required-packages
                 '(vertico marginalia orderless consult embark embark-consult
                           savehist compat))))

(ert-deftest config-smoke/package-archive-priority-changes-reread-cache ()
  (let ((package-archives nil)
        (package-archive-contents '((dummy-package)))
        (reloaded nil))
    (cl-letf (((symbol-function 'package-read-all-archive-contents)
               (lambda ()
                 (setq reloaded t))))
      (my/set-package-archives
       '(("melpa" . "https://melpa.org/packages/")
         ("gnu" . "https://elpa.gnu.org/packages/"))))
    (should reloaded)
    (should (equal package-archives
                   '(("melpa" . "https://melpa.org/packages/")
                     ("gnu" . "https://elpa.gnu.org/packages/"))))))

;;; config-smoke.el ends here
