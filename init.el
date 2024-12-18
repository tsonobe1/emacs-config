;; システムごとにconfig.orgのパスを設定
(require 'org)
(if (eq system-type 'windows-nt)
    (org-babel-load-file (expand-file-name "C:/emacs-org/config/myinit.org"))
  (org-babel-load-file (expand-file-name "~/.emacs.d/config/myinit.org")))
