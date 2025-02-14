(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
(setq system-time-locale "C")
(set-locale-environment "en_US.UTF-8")
(set-default 'buffer-file-coding-system 'utf-8)

;; use-packageのインストール
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(setq package-enable-at-startup nil)
   (setq load-prefer-newer t)
   (require 'org-tempo)

   ;; Babelの設定
   (setq org-babel-python-command
	 (if (eq system-type 'windows-nt)
	     "C:/emacs-org/env/bin/python"
	   "/Users/tsonobe/.emacs.d/env/bin/python"))
   (setq org-confirm-babel-evaluate nil)
   (setq org-startup-truncated nil)
   (org-babel-do-load-languages
    'org-babel-load-languages
'((python . t)
  (js . t)
  (C . t)
  (shell . t)
  (css . t)
  (sql . t)))

   (require 'ob-js)
   (add-to-list 'org-babel-load-languages '(js . t))
   (add-to-list 'org-babel-tangle-lang-exts '("js" . "js"))
   (require 'ob-C)

   ;; 行番号を常に表示する設定
   (global-display-line-numbers-mode t)


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

(defun my-toggle-truncate-lines ()
  "Toggle truncate-lines between nil and t."
  (interactive)
  (setq truncate-lines (not truncate-lines))
  (recenter))
(add-hook 'org-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c t") 'my-toggle-truncate-lines)))

(require 'package)
(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
	("melpa" . "http://melpa.org/packages/")))
(package-initialize)
(package-install 'org)

(require 'gnuplot)

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

(unless (package-installed-p 'flycheck)
  (package-refresh-contents)
  (package-install 'flycheck))

;; textlint のパスと設定ファイルを指定
(if (eq system-type 'windows-nt)
    ;; Windowsの場合
    (progn
      (setq flycheck-textlint-executable "C:/scoop/apps/nodejs16/current/bin/textlint.cmd") ;; textlintのパスを指定
      (setq flycheck-textlint-config "C:/emacs-org/.textlintrc.json")) ;; 設定ファイルを指定
  ;; Macの場合
  (progn
    (setq flycheck-textlint-executable "/Users/tsonobe/.nodebrew/node/v22.3.0/bin/textlint") ;; textlintのパスを指定（Homebrewなどでインストールした場合）
    (setq flycheck-textlint-config "/Users/tsonobe/.emacs.d/.textlintrc.json"))) ;; 設定ファイルのパス

;; checker for textlint
(flycheck-define-checker textlint
  "A linter using textlint."
  :command ("textlint" "--format" "unix" 
            source-inplace)
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ": "
            (id (one-or-more (not (any " "))))
            (message (one-or-more not-newline)
                     (zero-or-more "\n" (any " ") (one-or-more not-newline)))
            line-end))
  :modes (text-mode markdown-mode gfm-mode org-mode web-mode))
(add-to-list 'flycheck-checkers 'textlint)

;; textlintを使用するモードでFlycheckを有効化
(dolist (hook '(gfm-mode-hook markdown-mode-hook org-mode-hook))
  (add-hook hook 'flycheck-mode))


(setq flycheck-checkers '(textlint))
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

(unless (package-installed-p 'org-roam)
  (package-refresh-contents)
  (package-install 'org-roam))

(require 'org-roam)
(setq org-roam-directory
      (file-truename (if (eq system-type 'windows-nt)
			 "C:/emacs-org/org-roam"
		       "~/.emacs.d/org-roam")))
(setq org-roam-db-location
      (if (eq system-type 'windows-nt)
	  "C:/emacs-org/org-roam/org-roam.db"
	"~/.emacs.d/org-roam/org-roam.db"))
(org-roam-db-autosync-mode)

(global-set-key (kbd "C-c n f") 'org-roam-node-find)
(global-set-key (kbd "C-c n i") 'org-roam-node-insert)
(global-set-key (kbd "C-c n t") 'org-roam-buffer-toggle)
(global-set-key (kbd "C-c n l") 'org-roam-buffer-toggle)
(global-set-key (kbd "C-c n d") 'org-roam-dailies-capture-today)
(global-set-key (kbd "C-c n g") 'org-roam-graph)
(global-set-key (kbd "C-c n a") 'org-roam-alias-add)
(global-set-key (kbd "C-c n r") 'org-roam-ref-add)

(setq org-roam-completion-everywhere t)

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
 :unnarrowed t)))

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

(use-package doom-themes
  :custom
  (doom-themes-enable-italic t)
  (doom-themes-enable-bold t)
  :custom-face
  (doom-modeline-bar ((t (:background "#6272a4"))))
  :config
  (load-theme 'doom-dracula t)
  (doom-themes-neotree-config)
  (doom-themes-org-config))

(use-package doom-modeline
  :custom
  (doom-modeline-buffer-file-name-style 'truncate-with-project)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon nil)
  (doom-modeline-minor-modes nil)
  :hook
  (after-init . doom-modeline-mode)
  :config
  (line-number-mode 0)
  (column-number-mode 0))

(tool-bar-mode -1)

(use-package which-key
  :diminish which-key-mode
  :hook (after-init . which-key-mode))

(use-package amx)

(custom-set-variables
 '(custom-safe-themes
   '("b5fd9c7429d52190235f2383e47d340d7ff769f141cd8f9e7a4629a81abc6b19" default))
 '(package-selected-packages '(org doom-modeline doom-themes listen)))

(set-frame-parameter nil 'alpha '(90 . 80))
(add-to-list 'default-frame-alist '(alpha . (90 . 80)))

  (unless (eq system-type 'windows-nt)
    (defvar bootstrap-version)
    (let ((bootstrap-file
           (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
          (bootstrap-version 7))
      (unless (file-exists-p bootstrap-file)
        (with-current-buffer
            (url-retrieve-synchronously
             "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
             'silent 'inhibit-cookies)
          (goto-char (point-max))
          (eval-print-last-sexp)))
      (load bootstrap-file nil 'nomessage)))

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

(setq org-todo-keywords
      '((sequence "TODO(t)" "WAIT(w)" "SAMEDAY(s)" "|" "DONE(d)" "CANCEL(c)")))

;; Doneの時刻を記録する
(setq org-log-done 'time)

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
       "** SAMEDAY %?")))

;; org-agendaをC-c aにバインド
(global-set-key (kbd "C-c a") 'org-agenda)

;; agenda対象ディレクトリ
(setq org-agenda-files (list (if (eq system-type 'windows-nt)
				 "C:/emacs-org/inbox.org"
			       "~/.emacs.d/inbox.org")))

;; 行のハイライト
(add-hook 'org-agenda-mode-hook '(lambda () (hl-line-mode 1)))
(setq hl-line-face 'underline)

(setq org-agenda-log-mode-items '(closed clock))
(setq org-agenda-start-with-log-mode t)
(setq org-agenda-clockreport-mode t) ;; org-agendaで時計レポートを有効化

;; Org-modeのロード後にキーバインドを設定
(eval-after-load 'org-agenda
  '(progn
     ;; agenda内のTODOのclock in, out
     (define-key org-agenda-mode-map "i" 'org-agenda-clock-in)
     (define-key org-agenda-mode-map "o" 'org-agenda-clock-out)))

;; タスクが完了した時に自動的にclock outする
(setq org-clock-out-when-done t)

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
  (let ((secrets-file "~/.emacs.d/config/secrets.el"))
    (when (file-exists-p secrets-file)
      (load secrets-file)))

  ;; org-aiのインストールと設定
  (use-package org-ai
  :ensure t
  :commands (org-ai-mode
	     org-ai-global-mode)
  :init
  (add-hook 'org-mode-hook #'org-ai-mode) ; enable org-ai in org-mode
  (org-ai-global-mode) ; installs global keybindings on C-c M-a
  :config
  (setq org-ai-default-chat-model "gpt-4o-mini") ; if you are on the gpt-4 beta:
  (org-ai-install-yasnippets)) ; if you are using yasnippet and want `ai` snippets

  ;; 環境変数からAPIキーを取得する
  (setq org-ai-openai-api-token org-ai-api-key)

  ;; org-structure-template-alist にカスタムテンプレートを追加
(with-eval-after-load 'org
  (add-to-list 'org-structure-template-alist
               '("ai" . "ai")))
