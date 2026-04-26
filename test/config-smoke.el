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
  `((,my/python-exec-windows-path ,my/python-exec-non-windows-path)
    (,my/nodejs-path-prefix-windows ,my/nodejs-path-prefix-non-windows)
    (,my/mermaid-cli-windows-path ,my/mermaid-cli-non-windows-path)
    (,my/textlint-executable-windows-path ,my/textlint-executable-non-windows-path)
    (,my/textlint-config-windows-path ,my/textlint-config-non-windows-path)
    (,my/org-roam-directory-windows-path ,my/org-roam-directory-non-windows-path)
    (,my/org-roam-db-windows-path ,my/org-roam-db-non-windows-path)
    (,my/secrets-file-windows-path ,my/secrets-file-non-windows-path)
    (,my/inbox-file-windows-slash-path ,my/inbox-file-non-windows-path)
    (,my/inbox-file-windows-path ,my/inbox-file-non-windows-path))
  "Windows/non-Windows path pairs used by the shared config.")

(defconst config-test--windows-source-paths
  '("my/windows-sync-root"
    "my/windows-nodejs-root"
    "my/python-exec-windows-path"
    "my/inbox-file-windows-slash-path"
    "my/inbox-file-windows-path"
    "my/mermaid-cli-windows-path"
    "my/textlint-executable-windows-path"
    "my/textlint-config-windows-path"
    "my/nodejs-home-windows-path"
    "my/nodejs-bin-windows-path"
    "my/nodejs-path-windows"
    "my/nodejs-path-prefix-windows"
    "my/org-roam-directory-windows-path"
    "my/org-roam-db-windows-path"
    "my/secrets-file-windows-path"
    "my/org-roam-hugo-template-path")
  "Windows-related config symbols that should remain defined in `config/myinit.org`.")

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
  (should (eq (lookup-key global-map (kbd "C-c n f")) 'org-roam-node-find))
  (should (eq (lookup-key global-map (kbd "C-c n i")) 'org-roam-node-insert))
  (should (eq (lookup-key global-map (kbd "C-c n t")) 'org-roam-buffer-toggle))
  (should (eq (lookup-key global-map (kbd "C-c n d")) 'org-roam-dailies-capture-date))
  (should (eq (lookup-key global-map (kbd "C-c n u")) 'org-roam-ui-mode))
  (should (eq (lookup-key global-map (kbd "<f8>")) 'neotree-toggle)))

(ert-deftest config-smoke/orgローカルキーバインドが維持される ()
  (should (eq (lookup-key org-mode-map (kbd "C-c C-x n")) 'my/org-add-node-link-property))
  (should (eq (lookup-key org-mode-map (kbd "C-c C-p")) 'org-calc-progress))
  (should (eq (lookup-key org-mode-map (kbd "C-c C-n h")) 'org-hugo-export-to-md))
  (with-temp-buffer
    (org-mode)
    (should (eq (local-key-binding (kbd "C-c t"))
                'my-toggle-truncate-lines))))

(ert-deftest config-smoke/orgagendaローカルキーバインドが維持される ()
  (require 'org-agenda)
  (should (eq (lookup-key org-agenda-mode-map (kbd "i")) 'org-agenda-clock-in))
  (should (eq (lookup-key org-agenda-mode-map (kbd "o")) 'org-agenda-clock-out)))

(ert-deftest config-smoke/orgagendaの現在行強調設定が維持される ()
  (require 'org-agenda)
  (should (config-test--hook-contains-p 'org-agenda-mode-hook
                                        'my/org-agenda-enable-current-line-highlight))
  (should (eq hl-line-face 'underline)))

(ert-deftest config-smoke/neotree作成後の表示設定が維持される ()
  (should (config-test--hook-contains-p 'neo-after-create-hook
                                        'my/neotree-disable-line-wrapping))
  (with-current-buffer (get-buffer-create neo-buffer-name)
    (setq truncate-lines nil
          word-wrap t)
    (my/neotree-disable-line-wrapping nil)
    (should truncate-lines)
    (should-not word-wrap)))

(ert-deftest config-smoke/Mx拡張モードは既定で有効にならない ()
  (should-not (bound-and-true-p amx-mode)))

(ert-deftest config-smoke/org関連のワークフロー設定が維持される ()
  (should (equal org-todo-keywords
                 '((sequence "TODO(t)" "WAIT(w)" "SAMEDAY(s)" "|"
                             "DONE(d)" "CANCEL(c)"))))
  (should (eq org-log-done 'time))
  (should (equal org-agenda-files (list my/inbox-file-non-windows-path))))

(ert-deftest config-smoke/effort関連の設定と監視が維持される ()
  (should (equal org-global-properties
                 '(("Effort_ALL" . "0:05 0:10 0:15 0:30 0:45 1:00"))))
  (should (featurep 'org-duration))
  (should (advice-member-p #'my/org-check-effort-breakdown #'org-set-effort))
  (should (config-test--hook-contains-p 'org-after-todo-state-change-hook
                                        'my/org-check-effort-diff)))

(ert-deftest config-smoke/orgcaptureの保存先が維持される ()
  (should (equal (nth 3 (assoc "t" org-capture-templates))
                 `(file+headline ,my/inbox-file-non-windows-path "📥 INBOX")))
  (should (equal (nth 3 (assoc "w" org-capture-templates))
                 `(file+headline ,my/inbox-file-non-windows-path "📥 INBOX")))
  (should (equal (nth 3 (assoc "p" org-capture-templates))
                 `(file+headline ,my/inbox-file-non-windows-path "📥 INBOX")))
  (should (equal (nth 3 (assoc "s" org-capture-templates))
                 `(file+headline ,my/inbox-file-non-windows-path "🤔 Someday"))))

(ert-deftest config-smoke/orgの進捗集計結果が維持される ()
  (with-temp-buffer
    (org-mode)
    (insert "* Parent\n:PROPERTIES:\n:Storypoint: 8\n:Effort: 0:20\n:END:\n"
            "** DONE Task A\n:PROPERTIES:\n:Storypoint: 3\n:Effort: 0:05\n:END:\n"
            "** DONE Task B\n:PROPERTIES:\n:Storypoint: 5\n:Effort: 0:15\n:END:\n")
    (goto-char (point-min))
    (let (kill-ring)
      (org-calc-progress)
      (let ((result (current-kill 0)))
        (should (string-match-p "Storypoint: 100\\.0% (8/8)" result))
        (should (string-match-p "Effort: 100\\.0%" result))))))

(ert-deftest config-smoke/macos用のパス設定が維持される ()
  (should (equal org-roam-directory (file-truename my/org-roam-directory-non-windows-path)))
  (should (equal org-roam-db-location my/org-roam-db-non-windows-path))
  (should org-roam-completion-everywhere)
  (should (bound-and-true-p config-test--org-roam-autosync-enabled))
  (should (equal org-babel-python-command my/python-exec-non-windows-path))
  (should (equal ob-mermaid-cli-path my/mermaid-cli-non-windows-path))
  (should (equal flycheck-textlint-executable my/textlint-executable-non-windows-path))
  (should (equal flycheck-textlint-config my/textlint-config-non-windows-path)))

(ert-deftest config-smoke/orgroamのcapturetemplateが維持される ()
  (should (equal (assoc "n" org-roam-capture-templates)
                 '("n" "knowledge" plain "%?"
                   :target (file+head "knowledge/%<%Y%m%d%H%M%S>-${slug}.org"
                                      "#+title: ${title}\n#+date: %<%Y-%m-%d %H:%M:%S>\n#+filetags: :knowledge:\n")
                   :unnarrowed t)))
  (should (equal (assoc "d" org-roam-dailies-capture-templates)
                 '("d" "dailies" entry
                   "* %<%Y/%m/%d(%a)>\n* 勤務時間\n09:30 ~ 18:30\n* 作業\n\n* 所感\n\n* 次日の予定\n%?"
                   :target (file+head "%<%Y-%m-%d>.org"
                                      "#+title: %<%Y-%m-%d>\n#+options: toc:nil\n#+options: author:nil\n#+options: num:nil\n")))))

(ert-deftest config-smoke/orgroamのhugoテンプレートがブログ名由来で作られる ()
  (let* ((hugo-template (plist-get (nthcdr 4 (assoc "h" org-roam-capture-templates))
                                   :target))
         (path (cadr hugo-template))
         (expected-prefix (concat "hugo/"
                                 my/hugo-blog-name
                                 "/content/posts/")))
    (should (string-prefix-p expected-prefix path))
    (should (string-suffix-p "%<%Y%m%d%H%M%S>-${slug}.org" path))))

(ert-deftest config-smoke/macos用のnode設定が維持される ()
  (should (equal (car exec-path) (car my/nodejs-path-non-windows)))
  (should (string-prefix-p (car my/nodejs-path-non-windows)
                           (getenv "PATH"))))

(ert-deftest config-smoke/Windowsではnode用の実行パス候補がWindows側の一覧になる ()
  (let* ((system-type 'windows-nt)
         (node-exec-paths
          (my/os-path my/nodejs-path-windows
                     my/nodejs-path-non-windows)))
    (should (equal node-exec-paths
                   my/nodejs-path-windows))))

(ert-deftest config-smoke/Windowsでは主要パスがWindows側の文字列になる ()
  (let ((system-type 'windows-nt))
    (dolist (path-pair config-test--windows-path-pairs)
      (pcase-let ((`(,windows-path ,non-windows-path) path-pair))
        (should (equal (my/os-path windows-path non-windows-path)
                       windows-path))))))

(ert-deftest config-smoke/Windows向けのorg保存先文字列が維持される ()
  (let* ((system-type 'windows-nt)
         (inbox-file (my/os-path my/inbox-file-windows-path
                                 my/inbox-file-non-windows-path)))
    (should (equal `(file+headline ,inbox-file "📥 INBOX")
                   (list 'file+headline my/inbox-file-windows-path "📥 INBOX")))
    (should (equal `(file+headline ,inbox-file "🤔 Someday")
                   (list 'file+headline my/inbox-file-windows-path "🤔 Someday")))
    (should (equal (list (my/os-path my/inbox-file-windows-slash-path
                                     my/inbox-file-non-windows-path))
                   (list my/inbox-file-windows-slash-path)))))

(ert-deftest config-smoke/Windows向けの主要パス分岐が設定ソースに残っている ()
  (let ((source (config-test-file-contents (config-test-path "config" "myinit.org"))))
    (dolist (windows-path config-test--windows-source-paths)
      (let ((needle windows-path))
        (should (string-match-p (regexp-quote needle) source))))))

(ert-deftest config-smoke/主要なフック登録が維持される ()
  (should (config-test--hook-contains-p 'dired-mode-hook 'org-download-enable))
  (should (config-test--hook-contains-p 'org-mode-hook 'flycheck-mode))
  (should (config-test--hook-contains-p 'org-mode-hook 'org-ai-mode))
  (should (config-test--hook-contains-p 'org-mode-hook 'org-download-enable)))

(ert-deftest config-smoke/orgaiの認証設定が維持される ()
  (should (equal my/secrets-file-windows-path
                 (expand-file-name "config/secrets.el" my/windows-sync-root)))
  (should (equal my/secrets-file-non-windows-path
                 (my/secrets-file)))
  (should (equal org-ai-openai-api-token "config-test-org-ai-key"))
  (should (equal org-ai-default-chat-model "gpt-4.1-mini"))
  (should (bound-and-true-p config-test--org-ai-global-mode-enabled))
  (should (bound-and-true-p config-test--org-ai-yasnippets-installed)))

(ert-deftest config-smoke/Windows向けのsecrets設定が維持される ()
  (let ((system-type 'windows-nt))
    (should (equal (my/secrets-file) my/secrets-file-windows-path))
    (should (equal my/secrets-file-windows-path
                   (expand-file-name "config/secrets.el" my/windows-sync-root)))
    (should (equal (my/os-path my/secrets-file-windows-path
                               my/secrets-file-non-windows-path)
                   my/secrets-file-windows-path))))

(ert-deftest config-smoke/Windows向け主要定数が派生元基準で一貫する ()
  (let ((system-type 'windows-nt))
    (should (equal my/inbox-file-windows-path
                   (my/windows-path->backslash
                    (expand-file-name "inbox.org" my/windows-sync-root))))
    (should (equal my/mermaid-cli-windows-path
                   (expand-file-name "bin/mmdc.cmd" my/windows-nodejs-root)))
    (should (equal my/textlint-executable-windows-path
                   (expand-file-name "bin/textlint.cmd" my/windows-nodejs-root)))
    (should (equal my/textlint-config-windows-path
                   (expand-file-name ".textlintrc.json" my/windows-sync-root)))
    (should (equal my/nodejs-bin-windows-path
                   (expand-file-name "bin" my/nodejs-home-windows-path)))
    (should (equal my/nodejs-path-prefix-windows
                   (concat my/nodejs-home-windows-path
                           ";"
                           my/nodejs-bin-windows-path
                           ";")))))

(ert-deftest config-smoke/補完設定の既定値が維持される ()
  (should (equal completion-styles '(orderless basic)))
  (should (equal completion-category-overrides
                 '((file (styles basic partial-completion))))))

(ert-deftest config-smoke/補完有効化が実行される ()
  (should (fboundp 'my/enable-completion-enhancements))
  (should (fboundp 'vertico-mode))
  (should (bound-and-true-p completion-styles))
  (should (equal completion-styles '(orderless basic)))
  (should (member 'orderless completion-styles))
  (let ((vertico-called 0)
        (savehist-called 0)
        (vertico-args nil)
        (savehist-args nil))
    (cl-letf (((symbol-function 'vertico-mode)
               (lambda (&rest args)
                 (setq vertico-args args)
                 (setq vertico-called (1+ vertico-called))))
              ((symbol-function 'savehist-mode)
               (lambda (&rest args)
                 (setq savehist-args args)
                 (setq savehist-called (1+ savehist-called)))))
      (when (fboundp 'my/enable-completion-enhancements)
        (funcall 'my/enable-completion-enhancements)))
    (should (= vertico-called 1))
    (should (equal vertico-args '(1)))
    (should (or (not (fboundp 'savehist-mode))
                (equal savehist-args '(1))))
    (should (or (not (fboundp 'savehist-mode))
                (= savehist-called 1)))
    (should (bound-and-true-p completion-styles))))

(ert-deftest config-smoke/補完ヘルパーは未定義モードを安全に無視する ()
  (let ((value nil))
    (my/enable-minor-mode-with-on 'non-existent-emacs-mode)
    (should-not value)))

(ert-deftest config-smoke/補完ヘルパーは有効化モードを引数1で呼ぶ ()
  (let (enabled-with)
    (cl-letf (((symbol-function 'mylike-mode)
               (lambda (&rest args)
                 (setq enabled-with args))))
      (let ((mode-symbol 'mylike-mode))
        (my/enable-minor-mode-with-on mode-symbol))
      (should (equal enabled-with '(1))))))

(ert-deftest config-smoke/補完有効化は起動後に即時実行される ()
  (should (fboundp 'my/enable-completion-enhancements))
  (should (bound-and-true-p after-init-time))
  (should-not (memq 'my/enable-completion-enhancements
                    (default-value 'after-init-hook))))

(ert-deftest config-smoke/consultとembarkの連携拡張が読み込まれる ()
  (should (featurep 'embark-consult))
  (should (bound-and-true-p config-test--embark-consult-loaded)))

(ert-deftest config-smoke/org画像関連の既定値が維持される ()
  (should-not org-startup-with-inline-images)
  (should (equal org-image-actual-width '(600)))
  (should (equal (assoc "img" org-structure-template-alist)
                 '("img" . "#+CAPTION: \n#+ATTR_HTML: :width 600px :alt  :title "))))

(ert-deftest config-smoke/orgテンプレートの標準略記が維持される ()
  (should (equal (assoc "s" org-structure-template-alist)
                 '("s" . "src"))))

(ert-deftest config-smoke/orgテンプレートの追加略記が維持される ()
  (should (equal (assoc "ai" org-structure-template-alist)
                 '("ai" . "ai"))))

(ert-deftest config-smoke/oxhugo関連の既定値が維持される ()
  (should (featurep 'ox-hugo))
  (should org-export-with-tags)
  (should (equal org-hugo-base-dir my/hugo-blog-root))
  (should (eq org-hugo-front-matter-format 'yaml)))

(ert-deftest config-smoke/oxhugoのexporthookが維持される ()
  (should (config-test--hook-contains-p 'org-export-filter-paragraph-functions
                                        'my/ox-hugo-linkcard-paragraph-filter))
  (should (config-test--hook-contains-p 'org-export-filter-paragraph-functions
                                        'my/ox-hugo-figure-paragraph-filter))
  (should (config-test--hook-contains-p 'org-export-filter-paragraph-functions
                                        'my/ox-hugo-video-paragraph-filter))
  (should (config-test--hook-contains-p 'org-export-filter-src-block-functions
                                        'my/ox-hugo-src-block-filter))
  (should (config-test--hook-contains-p 'org-export-before-processing-hook
                                        'my/ox-hugo-promote-mermaid)))

(ert-deftest config-smoke/oxhugoのlinkcard段落変換が維持される ()
  (cl-letf (((symbol-function 'org-export-derived-backend-p)
             (lambda (&rest _args) t)))
    (should (equal
             (my/ox-hugo-linkcard-paragraph-filter
              "url=https://example.com\ntitle=Example\ndescription=Summary"
              'hugo nil)
             "{{< linkcard url=\"https://example.com\" title=\"Example\" description=\"Summary\" >}}\n"))))

(ert-deftest config-smoke/oxhugoのfigure段落変換が維持される ()
  (cl-letf (((symbol-function 'org-export-derived-backend-p)
             (lambda (&rest _args) t)))
    (should (equal
             (my/ox-hugo-figure-paragraph-filter
              "src=images/sample.png\ncaption=Sample\nwidth=600"
              'hugo nil)
             "{{< figure src=\"/images/sample.png\" caption=\"Sample\" width=\"600\" >}}\n"))))

(ert-deftest config-smoke/oxhugoのvideo段落変換が維持される ()
  (cl-letf (((symbol-function 'org-export-derived-backend-p)
             (lambda (&rest _args) t)))
    (should (equal
             (my/ox-hugo-video-paragraph-filter
              "video=videos/sample.mp4\nwidth=800"
              'hugo nil)
             "{{< video src=\"videos/sample.mp4\" width=\"800\" >}}\n"))))

(ert-deftest config-smoke/パッケージ初期化設定の既定値が維持される ()
  (should (equal package-archives
                 '(("melpa" . "https://melpa.org/packages/")
                   ("gnu" . "https://elpa.gnu.org/packages/"))))
  (should (eq package-enable-at-startup nil))
  (should (eq use-package-always-ensure t))
  (should (= (length my/package-selected-packages)
             (length (delete-dups my/package-selected-packages))))
  (should (cl-every (lambda (pkg) (memq pkg my/package-selected-packages))
                    my-required-packages))
  (should (equal (sort (mapcar #'symbol-name package-selected-packages) #'string<)
                 (sort (mapcar #'symbol-name my/package-selected-packages) #'string<)))
  (should (equal my-required-packages
                 '(use-package flycheck ob-mermaid vertico marginalia orderless
                               consult embark embark-consult compat))))

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
