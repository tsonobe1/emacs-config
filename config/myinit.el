;; Emacs 全体の言語環境を日本語に設定
(set-language-environment "Japanese")

;; デフォルトの文字コードを UTF-8 に設定
(prefer-coding-system 'utf-8)

;; 曜日・月名などのロケール表記を英語（C ロケール）にする
(setq system-time-locale "C")
(set-locale-environment "en_US.UTF-8")

;; バッファのデフォルトのファイル文字コードを UTF-8 に設定
(set-default 'buffer-file-coding-system 'utf-8)

;; Emacs 全体で常に行番号を表示
(global-display-line-numbers-mode t)

;; Emacs が .el（ソース）と .elc（コンパイル済みバイトコード）の両方を見つけたとき、自動的にソースのほうが新い方を読む
(setq load-prefer-newer t)

;; ---------------------------------------------
;; パッケージ管理の初期設定
;; ---------------------------------------------

;; Emacs の組み込みパッケージマネージャを有効にする
(require 'package)

(defun my/set-package-archives (archives)
  "Set `package-archives' to ARCHIVES and reload cached metadata when needed."
  (setq package-archives archives)
  ;; `package-install' consults the in-memory `package-archive-contents'
  ;; order, so re-read cache when archive priority changes mid-session.
  (when package-archive-contents
    (package-read-all-archive-contents)))

(defconst my/default-package-archives
  '(("gnu" . "https://elpa.gnu.org/packages/")
    ("melpa" . "https://melpa.org/packages/"))
  "Archive priority used during early package bootstrap.")

(defconst my/melpa-priority-package-archives
  '(("melpa" . "https://melpa.org/packages/")
    ("gnu" . "https://elpa.gnu.org/packages/"))
  "Archive priority used when MELPA packages should win resolution.")

;; 使用するパッケージアーカイブ（リポジトリ）を設定
;; MELPA は多数の最新パッケージを含んでいるので特に重要
(my/set-package-archives my/default-package-archives)

;; パッケージシステムを初期化（必ず package-archives 設定後に呼ぶ）
(package-initialize)

;; 1回だけ package-refresh-contents を走らせながら必要パッケージを入れる
(defvar my/package-contents-refreshed nil)

(defun my/ensure-packages-installed (packages)
  "Install PACKAGES, refreshing archives only once when needed."
  (dolist (pkg packages)
    (unless (package-installed-p pkg)
      (unless my/package-contents-refreshed
        (package-refresh-contents)
        (setq my/package-contents-refreshed t))
      (package-install pkg))))

(defconst my-required-packages
  '(use-package flycheck ob-mermaid vertico marginalia orderless consult
             embark embark-consult compat)
  "List of packages to ensure are installed at launch.")

(my/ensure-packages-installed my-required-packages)

(defconst my/package-selected-extra-packages
  '(doom-modeline doom-themes org-ai org-download org-roam org-roam-ui
                    neotree ox-hugo)
  "Extra packages to register in package metadata.")

(defconst my/package-selected-packages
  (delete-dups (append my-required-packages my/package-selected-extra-packages))
  "Package list registered by this config for package.el metadata.")

(defun my/os-path (windows-path non-windows-path)
  "Return WINDOWS-PATH on Windows, otherwise NON-WINDOWS-PATH."
  (if (eq system-type 'windows-nt)
      windows-path
    non-windows-path))

(defconst my/windows-sync-root "C:/emacs-org"
  "Shared sync root used for Windows file settings.")
(defconst my/windows-nodejs-root "C:/scoop/apps/nodejs16/current"
  "Shared Node.js root used on Windows.")

(defun my/windows-path->backslash (path)
  "Convert slashes in PATH to backslashes."
  (string-replace "/" "\\" path))

(defconst my/user-home
  (file-name-as-directory
   (or (getenv "HOME")
       (getenv "USERPROFILE")
       (expand-file-name "~")))
  "Current user's home directory.")

(defconst my/python-exec-windows-path
  (expand-file-name "env/bin/python" my/windows-sync-root)
  "Windows Python executable path.")
(defconst my/python-exec-non-windows-path
  (expand-file-name "env/bin/python" user-emacs-directory)
  "Non-Windows Python executable path.")

(defconst my/inbox-file-windows-slash-path
  (expand-file-name "inbox.org" my/windows-sync-root)
  "Windows inbox path in slash format.")
(defconst my/inbox-file-windows-path
  (my/windows-path->backslash my/inbox-file-windows-slash-path)
  "Windows inbox path in backslash format.")
(defconst my/inbox-file-non-windows-path
  (expand-file-name "inbox.org" user-emacs-directory)
  "Non-Windows inbox path.")

(defconst my/mermaid-cli-windows-path
  (expand-file-name "bin/mmdc.cmd" my/windows-nodejs-root)
  "Windows mermaid CLI path.")
(defconst my/nodejs-v22-bin-non-windows-path
  (expand-file-name ".nodebrew/node/v22.3.0/bin" my/user-home)
  "Non-Windows Node.js v22.x bin path.")
(defconst my/mermaid-cli-non-windows-path
  (expand-file-name "mmdc" my/nodejs-v22-bin-non-windows-path)
  "Non-Windows mermaid CLI path.")

(defconst my/textlint-executable-windows-path
  (expand-file-name "bin/textlint.cmd" my/windows-nodejs-root)
  "Windows textlint executable path.")
(defconst my/textlint-executable-non-windows-path
  (expand-file-name "textlint" my/nodejs-v22-bin-non-windows-path)
  "Non-Windows textlint executable path.")
(defconst my/textlint-config-windows-path
  (expand-file-name ".textlintrc.json" my/windows-sync-root)
  "Windows textlint config path.")
(defconst my/textlint-config-non-windows-path
  (expand-file-name ".textlintrc.json" user-emacs-directory)
  "Non-Windows textlint config path.")

(defconst my/nodejs-home-windows-path my/windows-nodejs-root
  "Windows Node.js home path.")
(defconst my/nodejs-bin-windows-path
  (expand-file-name "bin" my/nodejs-home-windows-path)
  "Windows Node.js bin path.")
(defconst my/nodejs-home-non-windows-path
  (expand-file-name ".nodebrew/current" my/user-home)
  "Non-Windows Node.js home path.")
(defconst my/nodejs-bin-non-windows-path
  (expand-file-name "bin" my/nodejs-home-non-windows-path)
  "Non-Windows Node.js bin path.")
(defconst my/nodejs-exec-non-windows-path
  (expand-file-name "node" my/nodejs-bin-non-windows-path)
  "Non-Windows Node.js executable path.")
(defconst my/nodejs-path-windows
  (list my/nodejs-home-windows-path
        my/nodejs-bin-windows-path)
  "Windows Node.js path candidates.")
(defconst my/nodejs-path-non-windows
  (list my/nodejs-exec-non-windows-path)
  "Non-Windows Node.js path candidates.")
(defconst my/nodejs-path-prefix-windows
  (concat my/nodejs-home-windows-path ";" my/nodejs-bin-windows-path ";")
  "Windows PATH prefix for Node.js.")
(defconst my/nodejs-path-prefix-non-windows
  my/nodejs-exec-non-windows-path
  "Non-Windows PATH prefix for Node.js.")

(defconst my/org-roam-directory-windows-path
  (expand-file-name "org-roam" my/windows-sync-root)
  "Windows org-roam directory path.")
(defconst my/org-roam-directory-non-windows-path
  (expand-file-name "org-roam" user-emacs-directory)
  "Non-Windows org-roam directory path.")
(defconst my/org-roam-db-windows-path
  (expand-file-name "org-roam/org-roam.db" my/windows-sync-root)
  "Windows org-roam DB path.")
(defconst my/org-roam-db-non-windows-path
  (expand-file-name "org-roam/org-roam.db" user-emacs-directory)
  "Non-Windows org-roam DB path.")

(defconst my/secrets-file-windows-path
  (expand-file-name "config/secrets.el" my/windows-sync-root)
  "Windows secrets file path.")
(defconst my/secrets-file-non-windows-path
  (expand-file-name "config/secrets.el" user-emacs-directory)
  "Non-Windows secrets file path.")

(defconst my/hugo-blog-root
  (expand-file-name "devs/tsono-blog" my/user-home)
  "Absolute path to the Hugo blog project root.")
(defconst my/hugo-blog-name
  (file-name-nondirectory (directory-file-name my/hugo-blog-root))
  "Blog directory name used in capture paths.")
(defconst my/org-roam-hugo-template-subdir
  (concat "hugo/" my/hugo-blog-name "/content/posts/")
  "Relative path for Hugo draft creation from org-roam capture.")
(defconst my/org-roam-hugo-template-path
  (concat my/org-roam-hugo-template-subdir
          "%<%Y%m%d%H%M%S>-${slug}.org")
  "org-roam capture target path for Hugo drafts.")

(defun my/inbox-file ()
  "Return the shared inbox.org path for the current OS."
  (my/os-path my/inbox-file-windows-path
              my/inbox-file-non-windows-path))

(defun my/inbox-file-slash ()
  "Return the shared inbox.org path using slash separators."
  (my/os-path my/inbox-file-windows-slash-path
              my/inbox-file-non-windows-path))

(defun my/secrets-file ()
  "Return the shared secrets.el path for the current OS."
  (my/os-path my/secrets-file-windows-path
              my/secrets-file-non-windows-path))

(defmacro my/after-org-load (&rest body)
  "Evaluate BODY after Org has loaded."
  (declare (indent defun))
  `(with-eval-after-load 'org
     ,@body))

(defun my/add-org-structure-template (shortcut template)
  "Add an Org structure TEMPLATE mapped by SHORTCUT."
  (add-to-list 'org-structure-template-alist
               (cons shortcut template)))

(require 'use-package)
;; 以降でuse-package に設定したパッケージが未インストールの場合、自動でインストールする
(setq use-package-always-ensure t)

(setq package-enable-at-startup nil)

;; org-tempo を読み込むことで、<s TAB などのテンプレ展開が有効になる
(my/after-org-load
  (require 'org-tempo))

;; Babelの設定
;; Python 実行コマンドのパスを OS によって切り替える
;; Windows の場合と macOS/Linux の場合で別の仮想環境を指定
(setq org-babel-python-command
	  (my/os-path my/python-exec-windows-path
		      my/python-exec-non-windows-path))

;; Org Babel 実行時の確認プロンプトを無効にする
(setq org-confirm-babel-evaluate nil)

;; 長い行を自動折り返し（truncated: nil にすると折り返し）
(setq org-startup-truncated nil)

;; org-babel によって実行可能な言語を登録
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t) ; Python
   (js . t)     ; JavaScript
   (C . t)      ; C
   (shell . t)  ; sh
   (css . t)    ; css
   (sql . t)))  ; sql

;; JavaScript 実行のためのモジュールを読み込む
(require 'ob-js)

;; js を tangle（コード抽出）した際の拡張子を .js にする
(add-to-list 'org-babel-tangle-lang-exts '("js" . "js"))

;; C用の Babel モジュールを読み込む
(require 'ob-C)

;; ---------------------------------------------
;; 行の折り返し表示をトグルする関数とキーバインド
;; ---------------------------------------------
;; nil → 折り返す、t → 折り返さずに右に流す
(defun my-toggle-truncate-lines ()
  "Toggle truncate-lines between nil and t."
  (interactive)
  (setq truncate-lines (not truncate-lines))
  (recenter))

(defun my/org-enable-truncate-lines-toggle ()
  "Enable the truncate-lines toggle keybinding in Org buffers."
  (local-set-key (kbd "C-c t") 'my-toggle-truncate-lines))

;; org-mode のバッファで C-c t にこのトグル関数をバインドする
(add-hook 'org-mode-hook #'my/org-enable-truncate-lines-toggle)

(setq ob-mermaid-cli-path
	(my/os-path my/mermaid-cli-windows-path
		    my/mermaid-cli-non-windows-path))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((mermaid . t)
   (scheme . t)))

;; ---------------------------------------------------
;; Flycheck + textlint を使った自然言語文法チェック設定
;; ---------------------------------------------------

;; textlint の実行ファイルと設定ファイルのパスを OS に応じて切り替える
;; ~./emacs.d配下のorgファイルで有効になる。それ以外のファイルからは
;; `設定ファイルのパスを指定` は無視されるため、ホームディレクトリにも
;; json を置いている。シンボリックリンクにするか、グローバルな設定を
;; 反映する方法を調べたほうがいいだろう。
(setq flycheck-textlint-executable
      (my/os-path my/textlint-executable-windows-path
                  my/textlint-executable-non-windows-path) ; textlintのパスを指定
      flycheck-textlint-config
      (my/os-path my/textlint-config-windows-path
                  my/textlint-config-non-windows-path)) ; 設定ファイルのパス

;; textlint を Flycheck のチェッカーとして定義する
(flycheck-define-checker textlint
  "A linter using textlint."
  :command ("textlint" "--format" "unix" 
	      source-inplace) ; ファイルに対して直接チェックを実行
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ": "
	      (id (one-or-more (not (any " ")))) ; エラーID
	      (message (one-or-more not-newline)
		       (zero-or-more "\n" (any " ") (one-or-more not-newline)))
	      line-end))
  :modes (text-mode org-mode web-mode)) ; 対応モード

;; 定義した textlint チェッカーを Flycheck に追加
(add-to-list 'flycheck-checkers 'textlint)

;; textlint を有効化するモードで flycheck-mode を自動オン
(add-hook 'org-mode-hook #'flycheck-mode)

;; デフォルトチェッカーを textlint のみに設定（他の checker を無効化）
(setq flycheck-checkers '(textlint))

;; エラーがあればミニバッファに表示（エラーリストバッファが開いていない時）
(setq flycheck-display-errors-function #'flycheck-display-error-messages-unless-error-list)

(let ((node-exec-paths
	 (my/os-path my/nodejs-path-windows
		    my/nodejs-path-non-windows))
	(node-path-prefix
	 (my/os-path my/nodejs-path-prefix-windows
		     my/nodejs-path-prefix-non-windows)))
  ;; exec-path に Node.js のパスを追加
  (setq exec-path (append node-exec-paths exec-path))

  ;; 環境変数 PATH にも追加
  (setenv "PATH" (concat node-path-prefix (getenv "PATH"))))

(setq org-todo-keywords
	'((sequence "TODO(t)" "WAIT(w)" "SAMEDAY(s)" "|" "DONE(d)" "CANCEL(c)")))

;; Doneの時刻を記録する
(setq org-log-done 'time)

;; -------------------------------------------------------------
;; org-roam の導入と初期設定
;; -------------------------------------------------------------

(use-package org-roam
  :bind (("C-c n f" . org-roam-node-find)
	     ("C-c n i" . org-roam-node-insert)
	     ("C-c n t" . org-roam-buffer-toggle)
	     ("C-c n l" . org-roam-buffer-toggle)
	     ("C-c n d" . org-roam-dailies-capture-date)
	     ("C-c n g" . org-roam-graph)
	     ("C-c n a" . org-roam-alias-add)
	     ("C-c n r" . org-roam-ref-add))
  :config
  ;; ノート保存ディレクトリとDBの設定（OS に応じて切り替え）
  ;; 他モードでも補完を有効にする（例: org-capture など）
  (setq org-roam-directory
        (file-truename (my/os-path my/org-roam-directory-windows-path
                                   my/org-roam-directory-non-windows-path))
        org-roam-db-location
        (my/os-path my/org-roam-db-windows-path
                    my/org-roam-db-non-windows-path)
        org-roam-completion-everywhere t)

  ;; org-roam のデータベース同期を自動で行う
  (org-roam-db-autosync-mode)

  ;; -------------------------------------------------------------
  ;; org-roam-capture-templates の設定
  ;; 各カテゴリごとに保存場所・ファイル名・タグを指定
  ;; -------------------------------------------------------------
  (setq org-roam-capture-templates
	    `(("d" "default" plain "%?"
	       :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
				  "#+title: ${title}\n#+date: %<%Y-%m-%d %H:%M:%S>\n")
	       :unnarrowed t)

	      ("n" "knowledge" plain "%?"
	       :target (file+head "knowledge/%<%Y%m%d%H%M%S>-${slug}.org"
				  "#+title: ${title}\n#+date: %<%Y-%m-%d %H:%M:%S>\n#+filetags: :knowledge:\n")
	       :unnarrowed t)

	      ("w" "work" plain "%?"
	       :target (file+head "work/%<%Y%m%d%H%M%S>-${slug}.org"
				  "#+title: ${title}\n#+date: %<%Y-%m-%d %H:%M:%S>\n#+filetags: :work:\n")
	       :unnarrowed t)

	      ("t" "tool" plain "%?"
	       :target (file+head "tool/%<%Y%m%d%H%M%S>-${slug}.org"
				  "#+title: ${title}\n#+date: %<%Y-%m-%d %H:%M:%S>\n#+filetags: :tool:\n")
	       :unnarrowed t)

	      ("r" "recipe" plain "%?"
	       :target (file+head "recipe/%<%Y%m%d%H%M%S>-${slug}.org"
				  "#+title: ${title}\n#+date: %<%Y-%m-%d %H:%M:%S>\n#+filetags: :recipe:\n")
	       :unnarrowed t)

	      ("m" "money" plain "%?"
	       :target (file+head "money/%<%Y%m%d%H%M%S>-${slug}.org"
				  "#+title: ${title}\n#+date: %<%Y-%m-%d %H:%M:%S>\n#+filetags: :money:\n")
	       :unnarrowed t)

	      ("c" "discuss" plain "%?"
	       :target (file+head "discuss/%<%Y%m%d%H%M%S>-${slug}.org"
				  "#+title: ${title}\n#+date: %<%Y-%m-%d %H:%M:%S>\n#+filetags: :discuss:\n")
	       :unnarrowed t)

	      ;; Hugo投稿用テンプレート（キー: h）
  ("h" "hugo" plain "%?"
   :target (file+head ,my/org-roam-hugo-template-path
				  "#+title: ${title}\n#+date: %<%Y-%m-%d>\n#+lastmod: %<%Y-%m-%d>\n#+description:\n#+tags:\n#+categories:\n#+draft: false\n#+hugo: true\n")
   :unnarrowed t)))

  ;; -------------------------------------------------------------
  ;; org-roam-dailies のテンプレート設定（日報用）
  ;; -------------------------------------------------------------
  (setq org-roam-dailies-capture-templates
	    '(("d" "dailies" entry
	       "* %<%Y/%m/%d(%a)>\n* 勤務時間\n09:30 ~ 18:30\n* 作業\n\n* 所感\n\n* 次日の予定\n%?"
	       :target (file+head "%<%Y-%m-%d>.org"
				  "#+title: %<%Y-%m-%d>\n#+options: toc:nil\n#+options: author:nil\n#+options: num:nil\n")))))

(use-package org-roam-ui
  :after org-roam
  :commands org-roam-ui-mode
  :bind ("C-c n u" . org-roam-ui-mode))

;; org-captureをC-c cにバインド
(global-set-key (kbd "C-c c") 'org-capture)

;; Org Captureテンプレートの設定
(let* ((inbox-file (my/inbox-file))
       (inbox-target `(file+headline ,inbox-file "📥 INBOX"))
       (someday-target `(file+headline ,inbox-file "🤔 Someday")))
  (setq org-capture-templates
	  `(("t" "Todo" entry ,inbox-target
	     "** TODO %?")
	    ("w" "Work Todo" entry ,inbox-target
	     "** TODO %?  :work:")
	    ("p" "Private Todo" entry ,inbox-target
	     "** TODO %?  :private:")
	    ("s" "Someday" entry ,someday-target
	     "** SAMEDAY %?")
	    ("h" "Hugo blog post" plain
	     (function my-org-hugo-new-post)
	     ""
	     :empty-lines 1))))

;; ---------------------------------------------------------
;; Org Agenda の基本設定
;; ---------------------------------------------------------

;; org-agendaをC-c aにバインド
(global-set-key (kbd "C-c a") 'org-agenda)

;; org-agenda に読み込ませるファイルを OS に応じて切り替え
;; ここでは inbox.org のみを対象
(setq org-agenda-files
	(list (my/inbox-file-slash)))

;; ---------------------------------------------------------
;; Org Agenda の表示に関する UI 設定
;; ---------------------------------------------------------

(defun my/org-agenda-enable-current-line-highlight ()
  "Highlight the current line in Org Agenda buffers."
  (hl-line-mode 1))

;; agenda バッファで現在行を強調表示（行のハイライト）
(add-hook 'org-agenda-mode-hook #'my/org-agenda-enable-current-line-highlight)

;; ハイライトスタイルを下線に
(setq hl-line-face 'underline)


;; ---------------------------------------------------------
;; Org Agenda のログ・クロック機能
;; ---------------------------------------------------------
;; 「ログモード」に表示する内容を指定（完了時刻とクロック時間）
(setq org-agenda-log-mode-items '(closed clock))

;; agenda を開いたときにログ表示モードを自動で有効化
(setq org-agenda-start-with-log-mode t)

;; クロックレポート（作業時間集計）を agenda 内で表示可能にする
(setq org-agenda-clockreport-mode t) ;; org-agendaで時計レポートを有効化


;; ---------------------------------------------------------
;; Org Agenda のキーバインド拡張（ロード後に定義）
;; ---------------------------------------------------------
(defmacro my/after-org-agenda-load (&rest body)
  "Evaluate BODY after org-agenda has loaded."
  (declare (indent defun))
  `(with-eval-after-load 'org-agenda
     ,@body))

(defun my/org-agenda-bind-clock-keys ()
  "Bind clock in and out commands in Org Agenda buffers."
  (define-key org-agenda-mode-map (kbd "i") #'org-agenda-clock-in)
  (define-key org-agenda-mode-map (kbd "o") #'org-agenda-clock-out))

;; org-agenda モードが読み込まれた後にカスタムキーバインドを定義
(my/after-org-agenda-load
  (my/org-agenda-bind-clock-keys))

;; タスクが完了した時に自動的にclock outする
(setq org-clock-out-when-done t)

;; ------------------------------------------------------------
;; Org の ASCII / Markdown エクスポートに関する設定
;; ------------------------------------------------------------

;; ASCII エクスポート時の見出し前後の空行を削除
(setq org-ascii-headline-spacing '(0 . 0))

;; Org-mode 読み込み後に Markdown エクスポート用のバックエンドを読み込む
(my/after-org-load
  (require 'ox-md nil t))


;; ------------------------------------------------------------
;; 空行をすべて削除する関数（Markdown 書き出し後の整形向け）
;; ------------------------------------------------------------
;; markdownに出力したバッファー内で使用することを想定している
(defun my/remove-blank-lines ()
  "Remove all blank lines in the current buffer."
  (interactive)
  (save-excursion
	(goto-char (point-min))
	(flush-lines "^[[:space:]]*$")))

;; C-c d で空行削除を実行
(global-set-key (kbd "C-c d") 'my/remove-blank-lines)

(defun my/org-add-node-link-property ()
    "現在のエントリに 'node-link' プロパティを追加する（複数登録可）。
    org-roam のノード補完を使ってリンクを選ぶ。"
    (interactive)
    (let* ((node (org-roam-node-read))
	   (id (org-roam-node-id node))
	   (title (org-roam-node-title node))
	   (link (org-link-make-string (concat "id:" id) title))
	   (current (org-entry-get nil "node-link")))
      (if current
	  (progn
	    (org-set-property "node-link" (concat current ", " link))
	    (message "プロパティ 'node-link' にリンク '%s' を追加しました。" link))
	(org-set-property "node-link" link)
	(message "'node-link' を '%s' に設定しました。" link))))


  ;; キーバインドを設定 (org-modeだけで有効)
  (my/after-org-load
    (define-key org-mode-map (kbd "C-c C-x n") #'my/org-add-node-link-property ))




  ;; ------------------------------------------------------------
  ;; Effort 関連の設定
  ;; ------------------------------------------------------------
  (my/after-org-load
    ;; Effort_ALL に列挙した値だけを C-c C-x e 時に補完
    (setq org-global-properties
	  '(("Effort_ALL" . "0:05 0:10 0:15 0:30 0:45 1:00")))

    ;; 時間文字列→分 に変換するために必要
    (require 'org-duration)

    ;; ------------------------------------------------------------
    ;; Effort 設定時に30分以上なら「break down」を推奨する
    ;; ------------------------------------------------------------
    (defun my/org-check-effort-breakdown (&rest _args)
      "Effort プロパティを設定した後に呼ばれ、30分以上なら分割を促す。"
      (when-let* ((effort-str (org-entry-get nil "Effort"))
		  (min         (org-duration-to-minutes effort-str)))
	(when (>= min 30)
	  (message
	   "⚠️ Effort が %d 分です。タスクを30分未満に分割（break down）することを検討してください。"
	   min))))

    ;; org-set-effort 実行後にチェック
    (advice-add 'org-set-effort :after #'my/org-check-effort-breakdown)

    (defcustom my/org-effort-diff-threshold 10
      "Effort と CLOCK 合計の差がこれ（分）を超えたときに理由を聞く。"
      :type 'integer)

    (defcustom my/org-effort-diff-property "WhyDiff"
      "差異の理由を記録する PROPERTIES のキー。"
      :type 'string)

    ;; LOGBOOK 内の CLOCK: 行を合計して分で返すヘルパー
    (defun my/org-get-logbook-total-minutes ()
      "現在のエントリのLOGBOOK内CLOCK合計を分単位で返す。"
      (save-excursion
	(let* ((subtree-end (save-excursion (org-end-of-subtree t)))
	       (log-start
		(when (re-search-forward "^:LOGBOOK:" subtree-end t)
		  (forward-line 1) (point)))
	       (log-end
		(when log-start
		  (save-excursion
		    (goto-char log-start)
		    (re-search-forward "^:END:" subtree-end t)
		    (match-beginning 0))))
	       (sum 0))
	  (when (and log-start log-end)
	    (goto-char log-start)
	    (while (re-search-forward
		    "^CLOCK:.*=>[ \t]*\\([0-9]+\\):\\([0-9]+\\)"
		    log-end t)
	      (let ((h (string-to-number (match-string 1)))
		    (m (string-to-number (match-string 2))))
		(setq sum (+ sum (+ (* 60 h) m))))))
	  sum)))

    ;; Effort vs CLOCK 差異チェック本体
    (defun my/org-check-effort-diff ()
      "TODO→DONE 時に Effort と CLOCK 合計を比較し、差が大きければ理由を記録。"
      (when (and (string= org-state "DONE")
		 (org-entry-get nil "Effort"))
	(let* ((effort-min (org-duration-to-minutes (org-entry-get nil "Effort")))
	       (total-min  (my/org-get-logbook-total-minutes))
	       (diff       (- total-min effort-min)))
	  (message "[EffortDiff] effort=%d 分, total=%d 分, diff=%+d 分"
		   effort-min total-min diff)
	  (when (> (abs diff) my/org-effort-diff-threshold)
	    (let ((reason
		   (read-string
		    (format "effort:%d分, total:%d分, diff:%+d分 Why?: "
			    effort-min total-min diff my/org-effort-diff-threshold))))
	      (org-entry-put nil my/org-effort-diff-property reason))))))

    ;; DONE への状態変更後にフック登録
    (add-hook 'org-after-todo-state-change-hook #'my/org-check-effort-diff))

(defun my-clocktable-write-reorder (&rest args)
  "Org clocktable をデフォルト出力したあと、
列を Headline | Effort | Time | … | % | WhyDiff の順に並べ替える。"
  ;; 1) まずはデフォルトの表を書き出す
  (apply #'org-clocktable-write-default args)

  ;; 2) その後、出力されたバッファ上で列を入れ替える
  (save-excursion
    (goto-char (point-min))
    ;; ── ヘッダー行の「Effort」がある行を検索
    (when (re-search-forward "^| *Effort *|" nil t)
      (beginning-of-line)

      ;; (a) Effort(1列目) を Headline(3列目) の後ろへ移動
      (dotimes (_ 2)
        (org-table-move-column-right))

      ;; (b) 残った最左列（元 WhyDiff）を末尾へ移動
      (let* ((line  (buffer-substring (line-beginning-position)
                                      (line-end-position)))
             ;; "|" で分割 → セル数を数える
             (cols  (length (split-string line "|" t)))
             ;; 現在は1列目なので、末尾まで動かす回数 = cols−1
             (moves (1- cols)))
        (org-table-goto-column 1)
        (dotimes (_ moves)
          (org-table-move-column-right))))))

;; ----------------------------------------------------------
;; Doom Themes の設定
;; ----------------------------------------------------------
(use-package doom-themes
  ;; Italic / Bold をテーマ内で有効にする
  :custom
  (doom-themes-enable-italic t)
  (doom-themes-enable-bold t)

  ;; モードラインのバーの色をカスタム設定
  :custom-face
  (doom-modeline-bar ((t (:background "#6272a4"))))

  ;; テーマを読み込む（t を渡すと確認なしで即時適用）
  :config
  (load-theme 'doom-badger t)

  ;; Neotree（ファイルツリー）の配色を Doom 仕様に
  (doom-themes-neotree-config)

  ;; Org-mode 用の色設定を有効にする
  (doom-themes-org-config))

;; ----------------------------------------------------------
;; Doom Modeline（ステータスライン）の設定
;; ----------------------------------------------------------
(use-package doom-modeline
  :custom
  ;; ファイル名表示形式：プロジェクトルートからの相対パス
  (doom-modeline-buffer-file-name-style 'truncate-with-project)

  ;; アイコン表示を有効にする（フォントが必要）
  (doom-modeline-icon t)

  ;; メジャーモードのアイコンは非表示
  (doom-modeline-major-mode-icon nil)

  ;; マイナーモード表示を非表示にして簡潔化
  (doom-modeline-minor-modes nil)

  :hook
  ;; Emacs 初期化後に自動で doom-modeline を有効化
  (after-init . doom-modeline-mode)

  :config
  ;; モードラインから行番号・列番号表示を削除（見た目をシンプルに）
  (line-number-mode 0)
  (column-number-mode 0))

;; -------------------------------------------------------------
;; カスタムテーマ・パッケージ情報の設定
;; -------------------------------------------------------------
(custom-set-variables
 '(custom-safe-themes
   '("b5fd9c7429d52190235f2383e47d340d7ff769f141cd8f9e7a4629a81abc6b19" default)))

(setq package-selected-packages my/package-selected-packages)

;; ----------------------------------------------------------
;; GUIのツールバーを非表示にして画面を広く使う
;; ----------------------------------------------------------
(tool-bar-mode -1)

;; -------------------------------------------------------------
;; ウィンドウの透過設定（foreground 90%, background 80%）
;; -------------------------------------------------------------
(set-frame-parameter nil 'alpha '(95 . 80))
(add-to-list 'default-frame-alist '(alpha . (95 . 80)))

(defun my/org-insert-sections (start end levels prefix char)
  "Insert sections from START to END with LEVELS characters (CHAR) and PREFIX.
If PREFIX is empty, show a message and do nothing."
  (interactive
   (list (read-number "Start number: " 0)
	     (read-number "End number: " 9)
	     (read-number "Levels (number of characters): " 2)
	     (read-string "Prefix: ")
	     (read-char-choice "Choose character (*, -, +): " '(?* ?- ?+))))
  (if (string-empty-p prefix)
	  (message "Please enter a prefix.")
	(dotimes (i (1+ (- end start)))
	  (insert (format "%s %s %d\n" (make-string levels char) prefix (+ start i))))))

(global-set-key (kbd "C-c i") 'my/org-insert-sections)

(defun check-org-properties-block-recursively ()
  "Check if the .org files in the org-roam-directory and its subdirectories contain the required :PROPERTIES: block."
  (interactive)
  (let* ((directory (file-name-as-directory org-roam-directory))
	      (total-files 0)
	      (ok-files 0)
	      (ng-files 0)
	      (ng-files-list '()))
	 (dolist (file (directory-files-recursively directory "\\.org$"))
	   (setq total-files (1+ total-files))
	   (with-temp-buffer
	     (insert-file-contents file)
	     (goto-char (point-min))
	     (if (and (re-search-forward ":PROPERTIES:" nil t)
		      (re-search-forward ":ID:" nil t)
		      (re-search-forward ":END:" nil t))
		 (setq ok-files (1+ ok-files))
	       (setq ng-files (1+ ng-files))
	       (push file ng-files-list))))
	 ;; 結果を表示
	 (message "Total files: %d" total-files)
	 (message "OK files: %d" ok-files)
	 (message "NG files: %d" ng-files)
	 (when ng-files-list
	   (message "NG files list:")
	   (dolist (file ng-files-list)
	     (message "%s" file)))))

;; neotreeのインストールと設定
(use-package neotree
  :config
  ;; 起動時にneotreeを開くキーを設定
  (global-set-key [f8] 'neotree-toggle)
  ;; neotreeのテーマを設定
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow))
  (defun my/neotree-disable-line-wrapping (&rest _args)
    "Disable line wrapping in the NeoTree buffer."
    (with-current-buffer (get-buffer neo-buffer-name)
      (setq truncate-lines t)
      (setq word-wrap nil)))
  ;; ディレクトリが更新されたら自動でneotreeをリフレッシュ
  (add-hook 'neo-after-create-hook #'my/neotree-disable-line-wrapping))

;; secrets.elを読み込む
(let ((secrets-file (my/secrets-file)))
  (when (file-exists-p secrets-file)
    (load secrets-file)))

(defun my/configure-org-ai-defaults ()
  "Apply the shared default settings for org-ai."
  (setq org-ai-openai-api-token org-ai-api-key
        org-ai-default-chat-model "gpt-4.1-mini")
  (org-ai-install-yasnippets))

;; org-aiのインストールと設定
(use-package org-ai
  :commands (org-ai-mode
	       org-ai-global-mode)
  :hook (org-mode . org-ai-mode)
  :init
  ;; グローバルに org-ai のキーバインド（C-c M-a）を有効化
  (org-ai-global-mode) ; installs global keybindings on C-c M-a

  :config
  ;; 環境変数からAPIキー取得、モデル指定、yasnippet をまとめて適用
  (my/configure-org-ai-defaults))


;; ----------------------------------------------------------
;; Org-mode の <ai + TAB に対応する構文テンプレートを追加
;; ----------------------------------------------------------
(my/after-org-load
  ;; <ai + tab --> #+begin_ai
  (my/add-org-structure-template "ai" "ai"))

;; Vertico 系パッケージは MELPA を優先して解決する
(my/set-package-archives my/melpa-priority-package-archives)
(require 'compat)

;; 補完候補を最大20行まで表示する
(setq vertico-count 20)

;; vertico-modeとmarginalia-modeを有効化する
(defun my/enable-minor-mode-with-on (mode)
  "Enable MODE with argument 1 when available."
  (when (fboundp mode)
    (funcall mode 1)))

(defun my/enable-completion-enhancements ()
  "Enable completion UX used by org-roam and related commands."
  (if (fboundp 'vertico-mode)
      (my/enable-minor-mode-with-on 'vertico-mode)
    (warn "vertico-mode is not available. Install package: vertico"))
  ;; savehist-modeを使ってVerticoの順番を永続化する
  (my/enable-minor-mode-with-on 'savehist-mode))
(if (bound-and-true-p after-init-time)
    (my/enable-completion-enhancements)
  (add-hook 'after-init-hook #'my/enable-completion-enhancements))

;; Marginaliaの設定
;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (my/enable-minor-mode-with-on 'marginalia-mode))

(defmacro my/after-consult-and-embark-load (&rest body)
  "Evaluate BODY after consult and embark have loaded."
  (declare (indent defun))
  `(with-eval-after-load 'consult
     (with-eval-after-load 'embark
       ,@body)))

;; embark-consultを読み込む
(my/after-consult-and-embark-load
  (require 'embark-consult))

;; orderlessの設定
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(defconst my/fibonacci-points '(1 2 3 5 8 13 21 34 55 89)
      "Fibonacci-like points available for Storypoint selection.")

    (defun my/org-set-story-point ()
      "Prompt for storypoint from Fibonacci values and set it as a property."
      (interactive)
      (let* ((choices (mapcar #'number-to-string my/fibonacci-points))
	     (choice (completing-read "Storypoint: " choices nil t)))
	(org-set-property "Storypoint" choice)))

    (defun my/org--get-storypoint ()
      "Get storypoint as number, or nil if not set or invalid."
      (let ((val (org-entry-get (point) "Storypoint")))
	(when (and val (string-match-p "^[0-9]+$" val))
	  (string-to-number val))))

    (defun my/org--get-effort-from-point (base-point base-minutes)
      "Compute effort string like 0:05 for a given point and base."
      (let ((total (* base-minutes base-point)))
	(format "%d:%02d" (/ total 60) (% total 60))))

(defun my/org-assign-efforts-based-on-storypoints (start end)
  "Assign Effort properties to child tasks based on storypoints.
Also set total Effort and Storypoint on the top-level heading (excluding itself from aggregation)."
  (interactive "r")
  (let ((entries '())
        (min-point most-positive-fixnum)
        (total-storypoints 0)
        (parent-marker (save-excursion
                         (goto-char start)
                         (org-back-to-heading t)
                         (point-marker)))) ;; 親見出しの位置を記録

    ;; collect all storypoints from children (excluding parent)
    (save-excursion
      (goto-char start)
      (while (re-search-forward org-heading-regexp end t)
        (save-excursion
          (org-back-to-heading t)
          (let ((pos (point)))
            (unless (= pos (marker-position parent-marker)) ;; 親を除外
              (let ((point-val (my/org--get-storypoint)))
                (when point-val
                  (push (cons (point-marker) point-val) entries)
                  (setq min-point (min min-point point-val))
                  (setq total-storypoints (+ total-storypoints point-val)))))))))

    (if (null entries)
        (message "No child tasks with Storypoint found.")
      (let* ((time-options '("0:01" "0:03" "0:05" "0:10" "0:15" "0:30" "0:45" "1:00"))
             (base-choice (completing-read
                           (format "Time for Storypoint %d (min): " min-point)
                           time-options nil t))
             (base-minutes (let* ((parts (split-string base-choice ":"))
                                  (h (string-to-number (car parts)))
                                  (m (string-to-number (cadr parts))))
                             (+ (* h 60) m)))
             (total-effort-minutes 0))
        ;; assign Effort properties to each child
        (dolist (entry entries)
          (let ((marker (car entry))
                (point-val (cdr entry)))
            (with-current-buffer (marker-buffer marker)
              (goto-char marker)
              (let ((effort (my/org--get-effort-from-point point-val base-minutes)))
                (org-set-property "Effort" effort)
                (let* ((parts (split-string effort ":"))
                       (effort-min (+ (* 60 (string-to-number (car parts)))
                                      (string-to-number (cadr parts)))))
                  (setq total-effort-minutes (+ total-effort-minutes effort-min)))))))

        ;; 親に合計をセット（自分自身の既存値は無視）
        (with-current-buffer (marker-buffer parent-marker)
          (goto-char parent-marker)
          (let ((total (format "%d:%02d" (/ total-effort-minutes 60) (% total-effort-minutes 60))))
            (org-set-property "Effort" total)
            (org-set-property "Storypoint" (number-to-string total-storypoints))
            (message "Total effort: %s, Total storypoints: %d" total total-storypoints)))))))



    ;; キーバインド
    (define-key org-mode-map (kbd "C-c C-x C-s") #'my/org-set-story-point)
    (define-key org-mode-map (kbd "C-c C-x C-d") #'my/org-assign-efforts-based-on-storypoints)

(defun my/org-progress-entry-at-point ()
  "Return the current entry progress as a cons of storypoint and effort minutes."
  (let* ((sp (string-to-number (or (org-entry-get nil "Storypoint") "0")))
         (eff-min (org-duration-string-to-minutes
                   (or (org-entry-get nil "Effort") "0:00"))))
    (cons sp eff-min)))

(defun my/org-done-progress-entries ()
  "Return progress entries for DONE items in the current tree."
  (org-map-entries #'my/org-progress-entry-at-point "TODO=\"DONE\"" 'tree))

(defun org-calc-progress ()
  "現在の見出しツリーの Storypoint と Effort の進捗を算出し、ミニバッファ表示とクリップボードにコピーする。"
  (interactive)
  (let* ((total-sp (string-to-number (or (org-entry-get nil "Storypoint") "0")))
         (total-eff-min
          (let ((s (or (org-entry-get nil "Effort") "0:00")))
            (org-duration-string-to-minutes s)))
         (entries (my/org-done-progress-entries))
         (done-sp (apply #'+ (mapcar #'car entries)))
         (done-eff-min (apply #'+ (mapcar #'cdr entries)))
         (sp-pct (if (> total-sp 0)
                     (* 100.0 (/ done-sp (float total-sp)))
                   0.0))
         (eff-pct (if (> total-eff-min 0)
                      (* 100.0 (/ done-eff-min (float total-eff-min)))
                    0.0))
         (result
          (format "Storypoint: %.1f%% (%d/%d)  Effort: %.1f%% (%s/%s)"
                  sp-pct done-sp total-sp
                  eff-pct
                  (org-duration-from-minutes done-eff-min)
                  (org-duration-from-minutes total-eff-min))))
    (message "%s" result)
    (kill-new result)))

;; org-calc-progress のキーバインドを C-c C-p に設定
(my/after-org-load
  (define-key org-mode-map (kbd "C-c C-p") #'org-calc-progress))

;; ------------------------------------------------------------
;; ox-hugo のインストールと設定（Org-roamからHugoへのエクスポート）
;; ------------------------------------------------------------
(use-package ox-hugo
  :after ox
  :bind (:map org-mode-map
         ("C-c C-n h" . org-hugo-export-to-md))
  :config
  ;; Hugo プロジェクトのベースディレクトリ
  (setq org-hugo-base-dir my/hugo-blog-root)

  ;; 開いている org ファイルのディレクトリにエクスポートする（ページバンドル対応）
  (setq org-hugo-auto-set-export-dir t)

  ;; タグと front matter 形式は Hugo 向けの既定値を使う
  (setq org-export-with-tags t
        org-hugo-front-matter-format 'yaml))

(defmacro my/after-ox-hugo-load (&rest body)
  "Evaluate BODY after ox-hugo has loaded."
  (declare (indent defun))
  `(with-eval-after-load 'ox-hugo
     ,@body))

(require 'cl-lib)

;;──────────────────────────────────────────────
;; Hugo 用 Org-capture テンプレートの追加
;;──────────────────────────────────────────────


(defun my-org-hugo-new-post ()
  "Create a new Hugo post using ox-hugo in YYYY/MM/slug/index.org format."
  (let* ((title (read-string "Post title: "))
         (default-slug (replace-regexp-in-string
                        "_+" "_"
                        (replace-regexp-in-string "[^[:word:][:digit:]]" "_" (downcase title))))
         (slug-input (read-string (format "Slug (default: %s): " default-slug) nil nil default-slug))
         (slug (replace-regexp-in-string
                "_+" "_"
                (replace-regexp-in-string "[^[:word:][:digit:]]" "_" slug-input)))
         (date (format-time-string "%Y-%m-%dT%H:%M:%S%z"))
         (year (format-time-string "%Y"))
         (month (format-time-string "%m"))
         (bundle-path (format "%s/%s/%s" year month slug))  ; YYYY/MM/slug
         (dir (expand-file-name (format "content/posts/%s" bundle-path)
                                org-hugo-base-dir))
         (file (expand-file-name "index.org" dir)))
    (make-directory dir t)
    (unless (file-exists-p file)
      (with-temp-buffer
        (insert (format "#+TITLE: %s\n" title))
        (insert "#+IMAGE:\n")
        (insert (format "#+DATE: %s\n" date))
        (insert "#+HUGO_AUTO_SET_LASTMOD: t\n")
        (insert "#+DESCRIPTION:\n")
        (insert "#+HUGO_TAGS:\n")
        (insert "#+HUGO_CATEGORIES:\n")
        (insert "#+DRAFT: false\n")
        (insert "#+mermaid: false\n")
        (insert (format "#+HUGO_BUNDLE: %s\n" bundle-path))
        (insert "#+EXPORT_FILE_NAME: index\n")
        (write-file file)))
    (find-file file)
    (goto-char (point-max))))



(use-package org-download
  :after org
  :hook ((dired-mode . org-download-enable)
         (org-mode . org-download-enable))
  :config
  ;; 画像は現在開いている org ファイルと同じディレクトリに保存
  (setq org-download-method 'directory)
  (setq org-download-image-dir "./") ; 現在のorgファイルと同じ場所
  (setq org-download-screenshot-method "screencapture -i %s")) ;; macOSの場合

;; Org の画像表示はデフォルトで展開せず、表示幅だけ統一する
(setq org-startup-with-inline-images nil
      org-image-actual-width '(600))

  ;; Org-modeで画像を挿入するためのキーバインド 後でちゃんと設定する
  ;; (define-key org-mode-map (kbd "C-c C-x i") 'org-download-clipboard)
  ;; (define-key org-mode-map (kbd "C-c C-x s") 'org-download-screenshot))

;; <img + TAB> で画像挿入のテンプレートを追加
(my/after-org-load
  (my/add-org-structure-template
   "img"
   "#+CAPTION: \n#+ATTR_HTML: :width 600px :alt  :title "))

(my/after-ox-hugo-load
  ;; 値から生URLだけを取り出す: <https://…> / https://… / ![](https://…)
  (defun my/ox-hugo--extract-url (s)
    (cond
     ((string-match "!\\[[^]]*\\](\\(https?://[^)[:space:]]+\\))" s)
      (match-string 1 s))
     ((string-match "<\\(https?://[^>[:space:]]+\\)>" s)
      (match-string 1 s))
     ((string-match "\\(https?://[^[:space:]]+\\)" s)
      (match-string 1 s))
     (t nil)))

  ;; タイトル/説明用の値を整形: 前後空白/引用符/<>を剥がし、" は &quot; に
  (defun my/ox-hugo--extract-text (s)
    (let ((txt (string-trim s)))
      (when (string-match "\\`[\"']\\(.*?\\)[\"']\\'" txt)
        (setq txt (match-string 1 txt)))
      (when (string-match "\\`<\\(.*\\)>\\'" txt)
        (setq txt (match-string 1 txt)))
      (setq txt (replace-regexp-in-string "\"" "&quot;" txt))
      txt))

  ;; src 値を抽出（"…" / <…> / [[file:…]] / URL / パス）
  (defun my/ox-hugo--extract-src (s)
    (let ((txt (string-trim s)))
      (when (string-match "\\`[\"']\\(.*?\\)[\"']\\'" txt)
        (setq txt (match-string 1 txt)))
      (when (string-match "\\`<\\(.*\\)>\\'" txt)
        (setq txt (match-string 1 txt)))
      (cond
       ((string-match "\\[\\[file:\\([^]]+\\)\\]\\]" txt)
        (match-string 1 txt))
       ((string-match "\\`https?://[^[:space:]]+\\'" txt)
        txt)
       (t txt))))

  (defun my/ox-hugo--quote (s)
    "Hugo shortcode 用に値を \"…\" で括り、内部の \" を &quot; に。"
    (format "\"%s\"" (replace-regexp-in-string "\"" "&quot;" s)))

  (defun my/ox-hugo-key-value-line-p (line)
    "Return non-nil when LINE is a key=value pair."
    (string-match-p "\\`[[:alpha:]]+\\s-*=[[:space:]]*.+\\'" line))

  (defun my/ox-hugo-all-key-value-lines-p (lines)
    "Return non-nil when every item in LINES is a key=value pair."
    (cl-every #'my/ox-hugo-key-value-line-p lines))

  (defun my/ox-hugo-any-line-starts-with-p (prefix lines)
    "Return non-nil when any item in LINES starts with PREFIX=."
    (cl-some (lambda (line)
               (string-match-p (format "\\`%s\\s-*=" (regexp-quote prefix)) line))
             lines))

  (defun my/ox-hugo-linkcard-paragraph-filter (text backend info)
    "段落を Hugo の linkcard に変換する。
- 段落が key=value 行のみで、url= がある → {{< linkcard url=… [image=…] [title=…] [description=…] >}}
- 単独URL段落                   → {{< linkcard \"…\" >}}"
    (when (org-export-derived-backend-p backend 'hugo)
      (let* ((trim  (string-trim text))
             (lines (split-string trim "\n+" t))
             url image title description)
        (dolist (l lines)
          (cond
           ((string-match "\\`url\\s-*=[[:space:]]*\\(.+\\)\\'" l)
            (setq url (my/ox-hugo--extract-url (match-string 1 l))))
           ((string-match "\\`image\\s-*=[[:space:]]*\\(.+\\)\\'" l)
            (setq image (my/ox-hugo--extract-url (match-string 1 l))))
           ((string-match "\\`title\\s-*=[[:space:]]*\\(.+\\)\\'" l)
            (setq title (my/ox-hugo--extract-text (match-string 1 l))))
           ((string-match "\\`description\\s-*=[[:space:]]*\\(.+\\)\\'" l)
            (setq description (my/ox-hugo--extract-text (match-string 1 l))))))
        (cond
         ((and url
               (my/ox-hugo-all-key-value-lines-p lines))
          (concat "{{< linkcard"
                  (format " url=\"%s\"" url)
                  (when image (format " image=\"%s\"" image))
                  (when title (format " title=\"%s\"" title))
                  (when description (format " description=\"%s\"" description))
                  " >}}\n"))
         ((or (string-match "\\`<https?://[^>[:space:]]+>\\'" trim)
              (string-match "\\`https?://[^[:space:]]+\\'" trim))
          (let ((u (my/ox-hugo--extract-url trim)))
            (if u (format "{{< linkcard \"%s\" >}}\n" u) text)))
         (t text)))))

  ;; ------------------------------
  ;; figure: key=value 段落から Hugo の figure を生成
  ;; ------------------------------
  (defun my/ox-hugo-figure-paragraph-filter (text backend info)
    "段落が key=value 行のみで src= が含まれる場合、
{{< figure src=... [caption=...] [title=...] [alt=...] [width=...] >}} に変換。
単独の [[file:...]] 段落は手を加えず ox-hugo の既定動作に委ねる。"
    (when (org-export-derived-backend-p backend 'hugo)
      (let* ((trim (string-trim text))
             (lines (split-string trim "\n+" t)))
        (cond
         ((string-match "\\`\\[\\[file:[^]]+\\]\\]\\'" trim)
          text)
         ((and (my/ox-hugo-all-key-value-lines-p lines)
               (my/ox-hugo-any-line-starts-with-p "src" lines))
          (let (src caption title alt width)
            (dolist (l lines)
              (cond
               ((string-match "\\`src\\s-*=[[:space:]]*\\(.+\\)\\'" l)
                (setq src (my/ox-hugo--extract-src (match-string 1 l))))
               ((string-match "\\`caption\\s-*=[[:space:]]*\\(.+\\)\\'" l)
                (setq caption (my/ox-hugo--extract-text (match-string 1 l))))
               ((string-match "\\`title\\s-*=[[:space:]]*\\(.+\\)\\'" l)
                (setq title (my/ox-hugo--extract-text (match-string 1 l))))
               ((string-match "\\`alt\\s-*=[[:space:]]*\\(.+\\)\\'" l)
                (setq alt (my/ox-hugo--extract-text (match-string 1 l))))
               ((string-match "\\`width\\s-*=[[:space:]]*\\(.+\\)\\'" l)
                (setq width (my/ox-hugo--extract-text (match-string 1 l))))))
            (when src
              (when (and (not (string-match-p "\\`https?://" src))
                         (not (string-prefix-p "/" src)))
                (setq src (concat "/" src)))
              (concat "{{< figure"
                      (format " src=%s" (my/ox-hugo--quote src))
                      (when caption (format " caption=%s" (my/ox-hugo--quote caption)))
                      (when title   (format " title=%s"   (my/ox-hugo--quote title)))
                      (when alt     (format " alt=%s"     (my/ox-hugo--quote alt)))
                      (when width   (format " width=%s"   (my/ox-hugo--quote width)))
                      " >}}\n"))))
         (t text)))))

  (defun my/ox-hugo-video-paragraph-filter (text backend info)
    "段落が key=value 行のみで video= が含まれる場合、{{< video src=... [width=...] >}} に変換。"
    (when (org-export-derived-backend-p backend 'hugo)
      (let* ((trim  (string-trim text))
             (lines (split-string trim "\n+" t)))
        (cond
         ((and (my/ox-hugo-all-key-value-lines-p lines)
               (my/ox-hugo-any-line-starts-with-p "video" lines))
          (let (video width)
            (dolist (l lines)
              (cond
               ((string-match "\\`video\\s-*=[[:space:]]*\\(.+\\)\\'" l)
                (setq video (my/ox-hugo--extract-src (match-string 1 l))))
               ((string-match "\\`width\\s-*=[[:space:]]*\\(.+\\)\\'" l)
                (setq width (my/ox-hugo--extract-text (match-string 1 l))))))
            (when video
              (concat "{{< video"
                      (format " src=%s" (my/ox-hugo--quote video))
                      (when width (format " width=%s" (my/ox-hugo--quote width)))
                      " >}}\n"))))
         (t text)))))

  ;; mermaid ソースブロックを Markdown の ```mermaid フェンスコードに変換
  (defun my/ox-hugo-src-block-filter (text backend info)
    "Convert #+begin_src mermaid ... #+end_src into ```mermaid fenced code."
    (when (org-export-derived-backend-p backend 'hugo)
      (let ((trim (string-trim text)))
        (when (string= (org-element-property :language (car (org-export-get-parent-element info))) "mermaid")
          (concat "```mermaid\n" trim "\n```")))))

  (defun my/ox-hugo-register-export-filters ()
    "Register shared ox-hugo export filters."
    ;; figure は先頭追加されるので、実行順は figure → linkcard を維持する。
    (add-hook 'org-export-filter-paragraph-functions
              #'my/ox-hugo-linkcard-paragraph-filter)
    (add-hook 'org-export-filter-paragraph-functions
              #'my/ox-hugo-figure-paragraph-filter)
    (add-hook 'org-export-filter-paragraph-functions
              #'my/ox-hugo-video-paragraph-filter)
    (add-hook 'org-export-filter-src-block-functions
              #'my/ox-hugo-src-block-filter))

  (my/ox-hugo-register-export-filters))

;; エクスポート時にソースコードを実行しない
(setq org-export-use-babel nil)

;; ox-hugo で export する直前に、#+mermaid: を HUGO front matter に昇格
(my/after-ox-hugo-load
  (defun my/ox-hugo-promote-mermaid (backend)
    "Promote `#+mermaid: true/false` to Hugo front matter via
`#+HUGO_CUSTOM_FRONT_MATTER: :mermaid true/false` on ox-hugo export."
    (when (org-export-derived-backend-p backend 'hugo)
      (save-excursion
        (goto-char (point-min))
        (when (re-search-forward "^#\\+mermaid:\\s-*\\(.*\\)$" nil t)
          (let* ((raw (downcase (string-trim (match-string 1))))
                 (bool (member raw '("t" "true" "yes" "on" "1")))
                 (newline (concat "#+HUGO_CUSTOM_FRONT_MATTER: :mermaid "
                                  (if bool "true" "false") "\n")))
            ;; 元の #+mermaid: 行は削除
            (beginning-of-line)
            (kill-whole-line)
            ;; 挿入位置：既存のヘッダ行群の直後（TITLE/DATE/HUGO_* 等の後）
            (goto-char (point-min))
            (while (looking-at "^#\\+\\(TITLE\\|AUTHOR\\|DATE\\|LASTMOD\\|DESCRIPTION\\|TAGS\\|CATEGORIES\\|DRAFT\\|HUGO_.*\\|EXPORT_FILE_NAME\\|IMAGE\\)\\b")
              (forward-line 1))
            (insert newline))))))

  (add-hook 'org-export-before-processing-hook #'my/ox-hugo-promote-mermaid))
