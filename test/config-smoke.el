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

(defconst config-test--windows-path-pairs
  '(("C:/emacs-org/env/bin/python" "/Users/tsonobe/.emacs.d/env/bin/python")
    ("C:/scoop/apps/nodejs16/current;C:/scoop/apps/nodejs16/current/bin;"
     "/Users/tsonobe/.nodebrew/current/bin/node")
    ("C:/scoop/apps/nodejs16/current/bin/mmdc.cmd"
     "/Users/tsonobe/.nodebrew/node/v22.3.0/bin/mmdc")
    ("C:/scoop/apps/nodejs16/current/bin/textlint.cmd"
     "~/.nodebrew/node/v22.3.0/bin/textlint")
    ("C:/emacs-org/.textlintrc.json" "~/.emacs.d/.textlintrc.json")
    ("C:/emacs-org/org-roam" "~/.emacs.d/org-roam")
    ("C:/emacs-org/org-roam/org-roam.db" "~/.emacs.d/org-roam/org-roam.db")
    ("C:/emacs-org/config/secrets.el" "~/.emacs.d/config/secrets.el")
    ("C:/emacs-org/inbox.org" "~/.emacs.d/inbox.org")
    ("C:\\emacs-org\\inbox.org" "~/.emacs.d/inbox.org"))
  "Windows/non-Windows path pairs used by the shared config.")

(defconst config-test--windows-source-paths
  '("C:/emacs-org/env/bin/python"
    "C:/scoop/apps/nodejs16/current"
    "C:/scoop/apps/nodejs16/current/bin"
    "C:/scoop/apps/nodejs16/current/bin/mmdc.cmd"
    "C:/scoop/apps/nodejs16/current/bin/textlint.cmd"
    "C:/emacs-org/.textlintrc.json"
    "C:/emacs-org/org-roam"
    "C:/emacs-org/org-roam/org-roam.db"
    "C:/emacs-org/config/secrets.el"
    "C:/emacs-org/inbox.org"
    "C:\\\\emacs-org\\\\inbox.org")
  "Windows path literals that should remain in `config/myinit.org`.")

(ert-deftest config-smoke/Emacsを起動するとorgソースを読む ()
  (with-temp-buffer
    (insert-file-contents (config-test-path "init.el"))
    (should (re-search-forward "org-babel-load-file" nil t))
    (should (re-search-forward "config/myinit.org" nil t))))

(ert-deftest config-smoke/smokeハーネスを読み込むと現在の設定がロード済みになる ()
  (should config-test--loaded))

(ert-deftest config-smoke/smokeハーネスで読み込むと隔離した生成設定を使う ()
  (should (string-prefix-p config-test--temp-user-emacs-directory
                           config-test--tangled-file))
  (should (file-exists-p config-test--tangled-file))
  (should-not (string= (expand-file-name "config/myinit.el" config-test-repo-root)
                       config-test--tangled-file)))

(ert-deftest config-smoke/設定ソースから再生成すると保存済み設定と一致する ()
  (should (string=
           (config-test-file-contents config-test--tangled-file)
           (config-test-file-contents (config-test-path "config" "myinit.el")))))

(ert-deftest config-smoke/org関連キーバインドが維持される ()
  (should (eq (lookup-key global-map (kbd "C-c c")) 'org-capture))
  (should (eq (lookup-key global-map (kbd "C-c a")) 'org-agenda))
  (should (eq (lookup-key global-map (kbd "C-c d")) 'my/remove-blank-lines))
  (should (eq (lookup-key global-map (kbd "C-c n u")) 'org-roam-ui-mode))
  (should (eq (lookup-key global-map (kbd "<f8>")) 'neotree-toggle)))

(ert-deftest config-smoke/Mx拡張モードは既定で有効にならない ()
  (should-not (bound-and-true-p amx-mode)))

(ert-deftest config-smoke/org関連のワークフロー設定が維持される ()
  (should (equal org-todo-keywords
                 '((sequence "TODO(t)" "WAIT(w)" "SAMEDAY(s)" "|"
                             "DONE(d)" "CANCEL(c)"))))
  (should (eq org-log-done 'time))
  (should (equal org-agenda-files '("~/.emacs.d/inbox.org"))))

(ert-deftest config-smoke/orgcaptureの保存先が維持される ()
  (should (equal (nth 3 (assoc "t" org-capture-templates))
                 '(file+headline "~/.emacs.d/inbox.org" "📥 INBOX")))
  (should (equal (nth 3 (assoc "w" org-capture-templates))
                 '(file+headline "~/.emacs.d/inbox.org" "📥 INBOX")))
  (should (equal (nth 3 (assoc "p" org-capture-templates))
                 '(file+headline "~/.emacs.d/inbox.org" "📥 INBOX")))
  (should (equal (nth 3 (assoc "s" org-capture-templates))
                 '(file+headline "~/.emacs.d/inbox.org" "🤔 Someday"))))

(ert-deftest config-smoke/macos用のパス設定が維持される ()
  (should (equal org-roam-directory (file-truename "~/.emacs.d/org-roam")))
  (should (equal org-roam-db-location "~/.emacs.d/org-roam/org-roam.db"))
  (should (equal org-babel-python-command "/Users/tsonobe/.emacs.d/env/bin/python"))
  (should (equal ob-mermaid-cli-path "/Users/tsonobe/.nodebrew/node/v22.3.0/bin/mmdc"))
  (should (equal flycheck-textlint-executable "~/.nodebrew/node/v22.3.0/bin/textlint"))
  (should (equal flycheck-textlint-config "~/.emacs.d/.textlintrc.json")))

(ert-deftest config-smoke/macos用のnode設定が維持される ()
  (should (equal (car exec-path) "/Users/tsonobe/.nodebrew/current/bin/node"))
  (should (string-prefix-p "/Users/tsonobe/.nodebrew/current/bin/node"
                           (getenv "PATH"))))

(ert-deftest config-smoke/Windowsではnode用の実行パス候補がWindows側の一覧になる ()
  (let* ((system-type 'windows-nt)
         (node-exec-paths
          (my/os-value '("C:/scoop/apps/nodejs16/current"
                         "C:/scoop/apps/nodejs16/current/bin")
                       '("/Users/tsonobe/.nodebrew/current/bin/node"))))
    (should (equal node-exec-paths
                   '("C:/scoop/apps/nodejs16/current"
                     "C:/scoop/apps/nodejs16/current/bin")))))

(ert-deftest config-smoke/Windowsでは主要パスがWindows側の文字列になる ()
  (let ((system-type 'windows-nt))
    (dolist (path-pair config-test--windows-path-pairs)
      (pcase-let ((`(,windows-path ,non-windows-path) path-pair))
        (should (equal (my/os-path windows-path non-windows-path)
                       windows-path))))))

(ert-deftest config-smoke/Windows向けのorg保存先文字列が維持される ()
  (let* ((system-type 'windows-nt)
         (inbox-file (my/os-path "C:\\emacs-org\\inbox.org"
                                 "~/.emacs.d/inbox.org")))
    (should (equal `(file+headline ,inbox-file "📥 INBOX")
                   '(file+headline "C:\\emacs-org\\inbox.org" "📥 INBOX")))
    (should (equal `(file+headline ,inbox-file "🤔 Someday")
                   '(file+headline "C:\\emacs-org\\inbox.org" "🤔 Someday")))
    (should (equal (list (my/os-path "C:/emacs-org/inbox.org"
                                     "~/.emacs.d/inbox.org"))
                   '("C:/emacs-org/inbox.org")))))

(ert-deftest config-smoke/Windows向けの主要パス分岐が設定ソースに残っている ()
  (let ((source (config-test-file-contents (config-test-path "config" "myinit.org"))))
    (dolist (windows-path config-test--windows-source-paths)
      (should (string-match-p (regexp-quote windows-path) source)))))

(ert-deftest config-smoke/主要なフック登録が維持される ()
  (should (config-test--hook-contains-p 'gfm-mode-hook 'flycheck-mode))
  (should (config-test--hook-contains-p 'markdown-mode-hook 'flycheck-mode))
  (should (config-test--hook-contains-p 'org-mode-hook 'flycheck-mode))
  (should (config-test--hook-contains-p 'org-mode-hook 'org-ai-mode))
  (should (config-test--hook-contains-p 'org-mode-hook 'org-download-enable)))

(ert-deftest config-smoke/補完設定の既定値が維持される ()
  (should (equal completion-styles '(orderless basic)))
  (should (equal completion-category-overrides
                 '((file (styles basic partial-completion))))))

(ert-deftest config-smoke/org画像関連の既定値が維持される ()
  (should-not org-startup-with-inline-images)
  (should (equal org-image-actual-width '(600)))
  (should (equal (assoc "img" org-structure-template-alist)
                 '("img" . "#+CAPTION: \n#+ATTR_HTML: :width 600px :alt  :title "))))

(ert-deftest config-smoke/パッケージ初期化設定の既定値が維持される ()
  (should (equal package-archives
                 '(("melpa" . "https://melpa.org/packages/")
                   ("gnu" . "https://elpa.gnu.org/packages/"))))
  (should (eq package-enable-at-startup nil))
  (should (eq use-package-always-ensure t))
  (should (equal package-selected-packages
                 '(org doom-modeline doom-themes)))
  (should (equal my-required-packages
                 '(vertico marginalia orderless consult embark embark-consult
                           savehist compat))))

(ert-deftest config-smoke/パッケージ取得先の優先順を変更すると一覧を再読込する ()
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
