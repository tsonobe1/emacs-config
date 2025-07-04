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

;; -------------------------------------------------------------
;; which-key：キーバインド補助（次に押すべきキーを教えてくれる）
;; -------------------------------------------------------------
(use-package which-key 
  :diminish which-key-mode ;; モードライン表示を簡素化
  :hook (after-init . which-key-mode)) ;; Emacs起動後に自動有効化

;; -------------------------------------------------------------
;; amx：M-x 実行履歴を強化（smexの後継）
;; -------------------------------------------------------------
(use-package amx)

;; ---------------------------------------------
;; パッケージ管理の初期設定
;; ---------------------------------------------

;; Emacs の組み込みパッケージマネージャを有効にする
(require 'package)

;; 使用するパッケージアーカイブ（リポジトリ）を設定
;; MELPA は多数の最新パッケージを含んでいるので特に重要
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
	("melpa" . "https://melpa.org/packages/")))

;; パッケージシステムを初期化（必ず package-archives 設定後に呼ぶ）
(package-initialize)

;; `org` パッケージを明示的にインストール
(package-install 'org)

;; ---------------------------------------------
;; gnuplot の読み込み
;; ---------------------------------------------

;; `gnuplot.el` を読み込む（描画コマンド連携用）
;; 必要に応じて `gnuplot-mode` や `org-babel-gnuplot` を併用
(require 'gnuplot)

;; パッケージ一覧を更新してインストール
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
;; 以降でuse-package に設定したパッケージが未インストールの場合、自動でインストールする
(setq use-package-always-ensure t)

(setq package-enable-at-startup nil)

;; -------------------------------------------------------------
;; straight.el のインストール（Windows 以外の環境でのみ実行）
;; -------------------------------------------------------------
(unless (eq system-type 'windows-nt)
  (defvar bootstrap-version)
  (let ((bootstrap-file
	 (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
	(bootstrap-version 7))

    ;; bootstrap.el が存在しない場合は、インターネットから取得してインストール
    (unless (file-exists-p bootstrap-file)
      (with-current-buffer
	  (url-retrieve-synchronously
	   "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
	   'silent 'inhibit-cookies)
	(goto-char (point-max))
	(eval-print-last-sexp)))

    ;; straight.el をロード
    (load bootstrap-file nil 'nomessage)))

;; org-tempo を読み込むことで、<s TAB などのテンプレ展開が有効になる
(require 'org-tempo)

;; Babelの設定
;; Python 実行コマンドのパスを OS によって切り替える
;; Windows の場合と macOS/Linux の場合で別の仮想環境を指定
(setq org-babel-python-command
      (if (eq system-type 'windows-nt)
	  "C:/emacs-org/env/bin/python"
	"/Users/tsonobe/.emacs.d/env/bin/python"))

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

;; dockerfile-modeの設定
(use-package dockerfile-mode
  :ensure t
  :mode ("Dockerfile\\'" . dockerfile-mode))

;; markdown-modeの設定
(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\'" . markdown-mode)
  :init (setq markdown-command "multimarkdown"))

;; yaml-modeの設定
(use-package yaml-mode
  :ensure t
  :mode ("\\.yml\\'" . yaml-mode)
  :mode ("\\.yaml\\'" . yaml-mode))

;; ---------------------------------------------
;; 行の折り返し表示をトグルする関数とキーバインド
;; ---------------------------------------------
;; nil → 折り返す、t → 折り返さずに右に流す
(defun my-toggle-truncate-lines ()
  "Toggle truncate-lines between nil and t."
  (interactive)
  (setq truncate-lines (not truncate-lines))
  (recenter))

;; org-mode のバッファで C-c t にこのトグル関数をバインドする
(add-hook 'org-mode-hook
	  (lambda ()
	    (local-set-key (kbd "C-c t") 'my-toggle-truncate-lines)))

(unless (package-installed-p 'ob-mermaid)
  (package-refresh-contents)
  (package-install 'ob-mermaid))

(if (eq system-type 'windows-nt)
    ;; Windowsの場合
    (progn
      (setq ob-mermaid-cli-path "C:/scoop/apps/nodejs16/current/bin/mmdc.cmd"))
  ;; Macの場合
  (progn
    (setq ob-mermaid-cli-path "/Users/tsonobe/.nodebrew/node/v22.3.0/bin/mmdc")))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((mermaid . t)
   (scheme . t)))

;; ---------------------------------------------------
;; Flycheck + textlint を使った自然言語文法チェック設定
;; ---------------------------------------------------

;; Flycheck（構文チェックツール）が未インストールならインストールする
(unless (package-installed-p 'flycheck)
  (package-refresh-contents)
  (package-install 'flycheck))

;; textlint の実行ファイルと設定ファイルのパスを OS に応じて切り替える
(if (eq system-type 'windows-nt)
    ;; Windowsの場合
    (progn
      (setq flycheck-textlint-executable "C:/scoop/apps/nodejs16/current/bin/textlint.cmd") ;; textlintのパスを指定
      (setq flycheck-textlint-config "C:/emacs-org/.textlintrc.json")) ;; 設定ファイルを指定
  ;; Macの場合
  ;; ~./emacs.d配下のorgファイルで有効になる。それ以外のファイルからは`設定ファイルのパスを指定`は無視されるため、ホームディレクトリにもjsonをおいている
  ;; シンボリックリンクにする or グローバルな設定を反映する方法を調べたほうがいいだろう
  (progn
    (setq flycheck-textlint-executable "~/.nodebrew/node/v22.3.0/bin/textlint") ;; textlintのパスを指定（Homebrewなどでインストールした場合）
    (setq flycheck-textlint-config "~/.emacs.d/.textlintrc.json"))) ;; 設定ファイルのパス

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
  :modes (text-mode markdown-mode gfm-mode org-mode web-mode)) ; 対応モード

;; 定義した textlint チェッカーを Flycheck に追加
(add-to-list 'flycheck-checkers 'textlint)

;; textlint を有効化するモードで flycheck-mode を自動オン
(dolist (hook '(gfm-mode-hook markdown-mode-hook org-mode-hook))
  (add-hook hook 'flycheck-mode))

;; デフォルトチェッカーを textlint のみに設定（他の checker を無効化）
(setq flycheck-checkers '(textlint))

;; エラーがあればミニバッファに表示（エラーリストバッファが開いていない時）
(setq flycheck-display-errors-function #'flycheck-display-error-messages-unless-error-list)

(if (eq system-type 'windows-nt)
    ;; Windowsの場合
    (progn
      ;; exec-path に Node.js のパスを追加
      (setq exec-path (append '("C:/scoop/apps/nodejs16/current" "C:/scoop/apps/nodejs16/current/bin") exec-path))

      ;; 環境変数 PATH にも追加
      (setenv "PATH" (concat "C:/scoop/apps/nodejs16/current;C:/scoop/apps/nodejs16/current/bin;" (getenv "PATH"))))

  ;; macOSの場合
  (progn
    ;; exec-path に Node.js のパスを追加（Homebrewでインストールした場合の例）
    (setq exec-path (append '("/Users/tsonobe/.nodebrew/current/bin/node") exec-path))

    ;; 環境変数 PATH にも追加
    (setenv "PATH" (concat "/Users/tsonobe/.nodebrew/current/bin/node" (getenv "PATH")))))

(setq org-todo-keywords
      '((sequence "TODO(t)" "WAIT(w)" "SAMEDAY(s)" "|" "DONE(d)" "CANCEL(c)")))

;; Doneの時刻を記録する
(setq org-log-done 'time)

;; -------------------------------------------------------------
;; org-roam の導入と初期設定
;; -------------------------------------------------------------

;; org-roam がインストールされていない場合はインストールする
(unless (package-installed-p 'org-roam)
  (package-refresh-contents)
  (package-install 'org-roam))

;; org-roam を読み込む
(require 'org-roam)

;; ノート保存ディレクトリの設定（OS に応じて切り替え）
(setq org-roam-directory
      (file-truename (if (eq system-type 'windows-nt)
			 "C:/emacs-org/org-roam"
		       "~/.emacs.d/org-roam")))

;; データベースファイルの保存先を指定
(setq org-roam-db-location
      (if (eq system-type 'windows-nt)
	  "C:/emacs-org/org-roam/org-roam.db"
	"~/.emacs.d/org-roam/org-roam.db"))

;; org-roam のデータベース同期を自動で行う
(org-roam-db-autosync-mode)


;; -------------------------------------------------------------
;; org-roam のキーバインド（主に C-c n で始まる）
;; -------------------------------------------------------------
(dolist (key-fn '(("C-c n f" . org-roam-node-find)
		  ("C-c n i" . org-roam-node-insert)
		  ("C-c n t" . org-roam-buffer-toggle)
		  ("C-c n l" . org-roam-buffer-toggle)
		  ("C-c n d" . org-roam-dailies-capture-date)
		  ("C-c n g" . org-roam-graph)
		  ("C-c n a" . org-roam-alias-add)
		  ("C-c n r" . org-roam-ref-add)))
  (global-set-key (kbd (car key-fn)) (cdr key-fn)))

;; 他モードでも補完を有効に（例: org-capture など）
(setq org-roam-completion-everywhere t)

;; -------------------------------------------------------------
;; org-roam-capture-templates の設定
;; 各カテゴリごとに保存場所・ファイル名・タグを指定
;; -------------------------------------------------------------
(setq org-roam-capture-templates
      '(("d" "default" plain "%?"
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
  :target (file+head "hugo/tsono-blog/content/posts/%<%Y%m%d%H%M%S>-${slug}.org"
    "#+title: ${title}\n#+date: %<%Y-%m-%d>\n#+lastmod: %<%Y-%m-%d>\n#+description:\n#+tags:\n#+categories:\n#+draft: false\n#+hugo: true\n")
   :unnarrowed t)))

;; -------------------------------------------------------------
;; org-roam-dailies のテンプレート設定（日報用）
;; -------------------------------------------------------------
(setq org-roam-dailies-capture-templates
      '(("d" "dailies" entry
	 "* %<%Y/%m/%d(%a)>\n* 勤務時間\n09:30 ~ 18:30\n* 作業\n\n* 所感\n\n* 次日の予定\n%?"
	 :target (file+head "%<%Y-%m-%d>.org"
			    "#+title: %<%Y-%m-%d>\n#+options: toc:nil\n#+options: author:nil\n#+options: num:nil\n"))))

;; org-captureをC-c cにバインド
(global-set-key (kbd "C-c c") 'org-capture)

;; Org Captureテンプレートの設定
(setq org-capture-templates
      `(("t" "Todo" entry (file+headline ,(if (eq system-type 'windows-nt)
					      "C:\\emacs-org\\inbox.org"
					    "~/.emacs.d/inbox.org") "📥 INBOX")
	 "** TODO %?")
	("w" "Work Todo" entry (file+headline ,(if (eq system-type 'windows-nt)
						   "C:\\emacs-org\\inbox.org"
						 "~/.emacs.d/inbox.org") "📥 INBOX")
	 "** TODO %?  :work:")
	("p" "Private Todo" entry (file+headline ,(if (eq system-type 'windows-nt)
						      "C:\\emacs-org\\inbox.org"
						    "~/.emacs.d/inbox.org") "📥 INBOX")
	 "** TODO %?  :private:")
	("s" "Someday" entry (file+headline ,(if (eq system-type 'windows-nt)
						 "C:\\emacs-org\\inbox.org"
					       "~/.emacs.d/inbox.org") "🤔 Someday")
	 "** SAMEDAY %?")
   ("h" "Hugo blog post" plain
       (function my-org-hugo-new-post)
       ""
       :empty-lines 1)))

;; ---------------------------------------------------------
;; Org Agenda の基本設定
;; ---------------------------------------------------------

;; org-agendaをC-c aにバインド
(global-set-key (kbd "C-c a") 'org-agenda)

;; org-agenda に読み込ませるファイルを OS に応じて切り替え
;; ここでは inbox.org のみを対象
(setq org-agenda-files (list (if (eq system-type 'windows-nt)
				 "C:/emacs-org/inbox.org"
			       "~/.emacs.d/inbox.org")))

;; ---------------------------------------------------------
;; Org Agenda の表示に関する UI 設定
;; ---------------------------------------------------------

;; agenda バッファで現在行を強調表示（行のハイライト）
(add-hook 'org-agenda-mode-hook '(lambda () (hl-line-mode 1)))

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
;; org-agenda モードが読み込まれた後にカスタムキーバインドを定義
(eval-after-load 'org-agenda
  '(progn
     ;; `i`: 現在の agenda 項目の clock-in（作業開始）
     (define-key org-agenda-mode-map "i" 'org-agenda-clock-in)

     ;; `o`: clock-out（作業終了）
     (define-key org-agenda-mode-map "o" 'org-agenda-clock-out)))

;; タスクが完了した時に自動的にclock outする
(setq org-clock-out-when-done t)

;; ------------------------------------------------------------
;; Org の ASCII / Markdown エクスポートに関する設定
;; ------------------------------------------------------------

;; ASCII エクスポート時の見出し前後の空行を削除
(setq org-ascii-headline-spacing '(0 . 0))

;; Org-mode 読み込み後に Markdown エクスポート用のバックエンドを読み込む
(eval-after-load "org"
  '(require 'ox-md nil t))


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
    (require 'org-roam)
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
  (with-eval-after-load 'org
    (define-key org-mode-map (kbd "C-c C-x n") #'my/org-add-node-link-property ))




  ;; ------------------------------------------------------------
  ;; Effort プロパティで選べる時間を制限する
  ;; ------------------------------------------------------------
  (with-eval-after-load 'org
    ;; Effort_ALL に列挙した値だけを C-c C-x e 時に補完
    (setq org-global-properties
	  '(("Effort_ALL" . "0:05 0:10 0:15 0:30 0:45 1:00"))))


  (with-eval-after-load 'org
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
    (advice-add 'org-set-effort :after #'my/org-check-effort-breakdown))


  (with-eval-after-load 'org
    (require 'org-duration)

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
   '("b5fd9c7429d52190235f2383e47d340d7ff769f141cd8f9e7a4629a81abc6b19" default))
 '(package-selected-packages '(org doom-modeline doom-themes listen)))

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

(global-set-key (kbd "C-c n u") 'org-roam-ui-mode)


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

 ;; 関数をインタラクティブにするための設定
 (provide 'check-org-properties-block-recursively)

;; neotreeのインストールと設定
(use-package neotree
  :ensure t
  :config
  ;; 起動時にneotreeを開くキーを設定
  (global-set-key [f8] 'neotree-toggle)
  ;; neotreeのテーマを設定
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow))
  ;; ディレクトリが更新されたら自動でneotreeをリフレッシュ
  (add-hook 'neo-after-create-hook
	    (lambda (_)
	      (with-current-buffer (get-buffer neo-buffer-name)
		(setq truncate-lines t)
		(setq word-wrap nil)))))

;; all-the-iconsのインストールと設定
(use-package all-the-icons
  :ensure t)

;; secrets.elを読み込む
(let ((secrets-file
       (if (eq system-type 'windows-nt)
	   "C:/emacs-org/config/secrets.el" ;; Windowsのパス
	 "~/.emacs.d/config/secrets.el"))) ;; MacやLinuxのパス
  (when (file-exists-p secrets-file)
    (load secrets-file)))

;; org-aiのインストールと設定
(use-package org-ai
  :ensure t
  :commands (org-ai-mode
	     org-ai-global-mode)
  :init
  ;; Org-mode バッファに入った時、自動で org-ai-mode を有効化
  (add-hook 'org-mode-hook #'org-ai-mode) ; enable org-ai in org-mode

  ;; グローバルに org-ai のキーバインド（C-c M-a）を有効化
  (org-ai-global-mode) ; installs global keybindings on C-c M-a

  :config
  ;; OpenAI モデルを指定
  (setq org-ai-default-chat-model "gpt-4.1-mini") ; if you are on the gpt-4 beta:

  ;; yasnippet 用の AI スニペットを読み込む（`ai` という展開補助）
  (org-ai-install-yasnippets)) ; if you are using yasnippet and want `ai` snippets

;; 環境変数からAPIキーを取得する
(setq org-ai-openai-api-token org-ai-api-key)


;; ----------------------------------------------------------
;; Org-mode の <ai + TAB に対応する構文テンプレートを追加
;; ----------------------------------------------------------
(with-eval-after-load 'org
  (add-to-list 'org-structure-template-alist
	       ;; <ai + tab --> #+begin_ai
	       '("ai" . "ai")))

(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu"   . "https://elpa.gnu.org/packages/")))

(unless package-archive-contents
  (package-refresh-contents))

;; 必要なパッケージを自動インストールする関数
(defvar my-required-packages
  '(vertico marginalia orderless consult embark embark-consult savehist)
  "List of packages to ensure are installed at launch.")

(unless package-archive-contents
  (package-refresh-contents))

(dolist (pkg my-required-packages)
  (unless (package-installed-p pkg)
    (package-install pkg)))

;; 補完スタイルにorderlessを利用する
(with-eval-after-load 'orderless
  (setq completion-styles '(orderless)))

;; 補完候補を最大20行まで表示する
(setq vertico-count 20)

;; vertico-modeとmarginalia-modeを有効化する
(defun my/enable-completion-enhancements ()
  (vertico-mode)
  ;; savehist-modeを使ってVerticoの順番を永続化する
  (savehist-mode))
(add-hook 'after-init-hook #'my/enable-completion-enhancements)

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
  (marginalia-mode))

;; embark-consultを読み込む
(with-eval-after-load 'consult
  (with-eval-after-load 'embark
    (require 'embark-consult)))

;; orderlessの設定
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(require 'orderless)
(setq completion-styles '(orderless basic)
      completion-category-overrides '((file (styles basic partial-completion))))

(defvar my/fibonacci-points '(1 2 3 5 8 13 21 34 55 89))

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

(defun org-calc-progress ()
  "現在の見出しツリーの Storypoint と Effort の進捗を算出し、ミニバッファ表示とクリップボードにコピーする。"
  (interactive)
  (let* ((total-sp (string-to-number (or (org-entry-get nil "Storypoint") "0")))
         (total-eff-min
          (let ((s (or (org-entry-get nil "Effort") "0:00")))
            (org-duration-string-to-minutes s)))
         (entries
          (org-map-entries
           (lambda ()
             (let* ((sp (string-to-number (or (org-entry-get nil "Storypoint") "0")))
                    (eff-min (org-duration-string-to-minutes
                              (or (org-entry-get nil "Effort") "0:00"))))
               (cons sp eff-min)))
           "TODO=\"DONE\"" 'tree))
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
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c C-p") #'org-calc-progress))

;; ------------------------------------------------------------
;; ox-hugo のインストールと設定（Org-roamからHugoへのエクスポート）
;; ------------------------------------------------------------
(use-package ox-hugo
  :ensure t
  :after ox
  :config
  ;; org-roam と ox-hugo を連携して使う際のオプションを推奨設定
(setq org-hugo-base-dir "~/devs/tsono-blog")
  (setq org-hugo-section "posts")) ;; デフォルトのセクションを "posts" に設定

;; Org-roamノードを ox-hugo でエクスポートするショートカット
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c C-n h") #'org-hugo-export-to-md))


;;──────────────────────────────────────────────
;; Hugo 用 Org-capture テンプレートの追加
;;──────────────────────────────────────────────

(require 'ox-hugo)

(defconst my/hugo-blog-dir
  (expand-file-name "~/devs/tsono-blog/content/posts/")
  "Hugo サイトの content/posts/ ディレクトリへの絶対パス（末尾にスラッシュ付き）")

(defun my-org-hugo-new-post ()
  "Create a new Hugo post directory and open an org file inside it."
  (let* ((title (read-string "Post title: "))
         (date (format-time-string "%Y%m%d"))
         (datetime (format-time-string "%Y-%m-%dT%H:%M:%S%z"))
         (slug (replace-regexp-in-string
                "_+" "_"
                (replace-regexp-in-string "[^[:word:][:digit:]]" "_" title)))
         (dir (expand-file-name (format "~/devs/tsono-blog/content/posts/%s_%s" date slug)))
         (file (expand-file-name "index.org" dir)))
    (make-directory dir t)
    (unless (file-exists-p file)
      (with-temp-buffer
        (insert (format "#+TITLE: %s\n" title))
        (insert (format "#+DATE: %s\n" datetime))
        (insert "#+HUGO_AUTO_SET_LASTMOD: t\n")
        (insert "#+DESCRIPTION:\n")
        (insert "#+TAGS:\n")
        (insert "#+CATEGORIES:\n")
        (insert "#+DRAFT: false\n")
        (write-file file)))
    (find-file file)
    (goto-char (point-max))))
