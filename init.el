;;; proxy for url.el
;(setq url-proxy-services
;      '(("http" . "172.16.220.102:3128")
;        ("https" . "172.16.220.102:3128")))

;; オリジナルの .elを持ってきたいときには以下を入れる
;;(setq load-path (cons (expand-file-name "~/.emacs.d/site-lisp/") load-path))


;;; package.el
;;; http://qiita.com/tadsan/items/6c658cc471be61cbc8f6 を参考にするといい
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;;(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t); httpsで通らないときこちら
(package-initialize)

;; 自動でpackageをロードする設定は以下をみて今後修正する
;;;https://qiita.com/regashia/items/057b682dd29fbbdadd52


;;; テーマ
(load-theme 'deeper-blue t)

;;; helm
(unless (require 'helm nil t) (progn (package-refresh-contents) (package-install 'helm))) ;; helmは最初なのでここだけパッケージ一覧を更新している
(unless (require 'helm-ag nil t) (package-install 'helm-ag))
(helm-mode 1) ;helmを常に有効
;;(define-key helm-find-files-map (kbd "TAB") 'helm-execute-persistent-action) ;;tabはアクション選択
(define-key global-map (kbd "M-x") 'helm-M-x) ;;M-xの検索をhelmで行う
(define-key global-map (kbd "C-x r b") #'helm-filtered-bookmarks)
(define-key global-map (kbd "C-x C-f") #'helm-find-files) ;;elscreen-find-fileで置き換え予定
(define-key global-map (kbd "C-x b") 'helm-mini)
(define-key global-map (kbd "C-x C-b") 'helm-buffers-list)
(define-key global-map (kbd "C-x g") 'helm-ag)
(define-key global-map (kbd "M-y") 'helm-show-kill-ring)
(defvar my-helm-map (make-sparse-keymap) "my original helm keymap binding F7 and C-;")
(defalias 'my-helm-prefix my-helm-map)
(define-key global-map [f7] 'my-helm-prefix)
(define-key global-map (kbd "C-;") 'my-helm-prefix) ;; ネイティブwindowの時にしかキーが取れない rloginでは C-;を"\030@c;"に割り当てる
(define-key my-helm-map (kbd "h") 'helm-mini)
(define-key my-helm-map (kbd "r") 'helm-recentf)
(define-key my-helm-map (kbd "i") 'helm-imenu)
(define-key my-helm-map (kbd "k") 'helm-show-kill-ring)
(define-key my-helm-map (kbd "o") 'helm-occur)
(define-key my-helm-map (kbd "x") 'helm-M-x)
(define-key my-helm-map (kbd "f") 'helm-browse-project) ;; git内に関係するファイル全部を絞り込める
;; windows版だと文字コード問題が起こる
;; http://qiita.com/fujii_0v0/items/d6e96304e913027f48ac 時期を見てコンパイル方法を確立
(define-key my-helm-map (kbd "g") 'helm-ag)

;;; helm-descbinds C-h bの結果を絞りこめる
(unless (require 'helm-descbinds nil t) (package-install 'helm-descbinds))
(helm-descbinds-mode)

;;; helm-gtags
(unless (require 'helm-gtags nil t) (package-install 'helm-gtags))
;; Enable helm-gtags-mode
(add-hook 'go-mode-hook (lambda () (helm-gtags-mode)))
(add-hook 'python-mode-hook (lambda () (helm-gtags-mode)))
(add-hook 'ruby-mode-hook (lambda () (helm-gtags-mode)))
;; gtag setting
(setq helm-gtags-path-style 'root)
(setq helm-gtags-auto-update t)
;; key bind あまり好きじゃないな C-:系に後で変える
(add-hook 'helm-gtags-mode-hook
          '(lambda ()
             (local-set-key (kbd "M-g") 'helm-gtags-dwim)
             (local-set-key (kbd "M-s") 'helm-gtags-show-stack)
             (local-set-key (kbd "M-p") 'helm-gtags-previous-history)
             (local-set-key (kbd "M-n") 'helm-gtags-next-history)
             (local-set-key (kbd "M-l") 'helm-gtags-select)
             ;;入力されたタグの定義元へジャンプ
             ;;(local-set-key (kbd "M-t") 'helm-gtags-find-tag)
             ;;入力タグを参照する場所へジャンプ
             ;;(local-set-key (kbd "M-r") 'helm-gtags-find-rtag)
             ))

;; mode-hook
(add-hook 'c-mode-hook 'helm-gtags-mode)

;;https://www.emacswiki.org/emacs/HelmSwoop
;; helmSwoopを入れる

;;; company-mode
;;; http://qiita.com/sune2/items/b73037f9e85962f5afb7
;;; http://qiita.com/syohex/items/8d21d7422f14e9b53b17
(unless (require 'company nil t) (package-install 'company))
(global-company-mode) ; 全バッファで有効にする
(setq company-idle-delay 0) ; デフォルトは0.5
(setq company-minimum-prefix-length 2) ; デフォルトは4
(setq company-selection-wrap-around t) ; 候補の一番下でさらに下に行こうとすると一番上に戻る
(define-key company-active-map (kbd "M-n") nil)
(define-key company-active-map (kbd "M-p") nil)
(define-key company-active-map (kbd "C-n") 'company-select-next)
(define-key company-active-map (kbd "C-p") 'company-select-previous)
(define-key company-active-map (kbd "C-h") nil)
(defun company--insert-candidate2 (candidate)
  (when (> (length candidate) 0)
    (setq candidate (substring-no-properties candidate))
    (if (eq (company-call-backend 'ignore-case) 'keep-prefix)
        (insert (company-strip-prefix candidate))
      (if (equal company-prefix candidate)
          (company-select-next)
          (delete-region (- (point) (length company-prefix)) (point))
        (insert candidate))
      )))
(defun company-complete-common2 ()
  (interactive)
  (when (company-manual-begin)
    (if (and (not (cdr company-candidates))
             (equal company-common (car company-candidates)))
        (company-complete-selection)
      (company--insert-candidate2 company-common))))
(define-key company-active-map [tab] 'company-complete-common2)
(define-key company-active-map [backtab] 'company-select-previous) ; おまけ
;;;https://qiita.com/sune2/items/c040171a0e377e1400f6 でc/c++の補完ができる


;;; elscreen  emacs版screen キーバインドが気に入らない
(unless (require 'elscreen nil t) (package-install 'elscreen))
(elscreen-start)
(define-key elscreen-map (kbd "C-z") 'elscreen-toggle) ; C-zC-zを一つ前のwindowにする
(define-key my-helm-map (kbd "C-;") 'elscreen-toggle) ; C-;C-;を一つ前のwindowにする
(setq elscreen-tab-display-kill-screen nil) ;タブの先頭に[x]を表示しない
(setq elscreen-tab-display-control nil) ; header-lineの先頭に[<->]を表示しない
(define-key global-map (kbd "C-x C-f") #'elscreen-find-file)
(define-key global-map (kbd "C-x d") 'elscreen-dired)
(defun elscreen-kill-and-kill-buffer ()
  (interactive)
  (unless (string= (buffer-name) "*scratch*") (kill-buffer))
  ;;(kill-buffer)
  (elscreen-kill))
(define-key global-map (kbd "C-x k") 'elscreen-kill-and-kill-buffer)
;;  (if (eq 1 (length (elscreen-get-screen-list))) ;;elscreenのタブの数はこれでわかる


;;helm-recentfにelscreenの別windowを用いようと思ったが失敗(いつかチャレンジする)
;;(setq helm-type-file-actions (cons '("Find file elscreen" . elscreen-find-file) helm-type-file-actions))

;;; helm-elscreen
(unless (require 'helm-elscreen nil t) (package-install 'helm-elscreen))
(setq helm-type-file-actions (cons '("Find file Elscreen" . helm-elscreen-find-file) helm-type-file-actions))
(setq helm-type-buffer-actions (cons '("Find buffer elscreen" . helm-elscreen-find-buffer) helm-type-buffer-actions))


;;; sr-speedbar
;;; デフォルトでくっついてくるspeedbarをフレーム(window内に入れる)
(unless (require 'sr-speedbar nil t) (package-install 'sr-speedbar))
(setq sr-speedbar-right-side nil)
(define-key global-map [f8] 'sr-speedbar-toggle) ;F8キーをspeedbarのon/offにする

;;; org-mode
;;; #+ の補完をやってくれるようにする
(defun my-org-mode-hook ()
  (add-hook 'completion-at-point-functions 'pcomplete-completions-at-point nil t))
(add-hook 'org-mode-hook #'my-org-mode-hook)

;;; org-mode
;;; 最新のorgmodeでditaaが動かないので ubuntu16.04付属のorgを使う
;;; 埋め込みは http://tanehp.ec-net.jp/heppoko-lab/prog/resource/org_mode/org_mode_memo.html が参考になる
;;(require ‘org-babel-init)
(setq org-todo-keywords '((sequence "TODO(t)" "WAIT(w)" "|" "DONE(d)" "SOMEDAY(s)"))) ;; TODO状態
(setq org-log-done 'time);; DONEの時刻を記録
;; メモ書きに大変便利、結果は#+begin_src ruby :exports resultsで出力
(org-babel-do-load-languages ;
 'org-babel-load-languages
 '((dot .t) (ditaa .t) (gnuplot .t) (emacs-lisp .t)
   (ruby .t) (sh .t) )) ;;デフォルトはemacslispのみ
;; ditaaの設定
;; #+begin_src ditaa :file images/ditaa-test.png :cmdline -s 2 日本語を通したいときには左記のヘッダにする
;; http://d.hatena.ne.jp/tamura70/20100317/org を参照のこと
;;(setq org-ditaa-jar-path (expand-file-name "~/bin/jditaa.jar")) ;; ditaaのパス
(setq org-ditaa-jar-path (expand-file-name "~/bin/ditaa0_9.jar")) ;; ditaaのパス
(setq org-confirm-babel-evaluate nil) ;; コードを評価するとき尋ねない ditaa作成時の問い合わせをoff

;;;
;;; 拡張したpictureモードC-矢印で線がかける
(define-key org-mode-map (kbd "\C-cp") 'picture-mode) ;; org-modeではC-cpで起動
(add-hook 'picture-mode-hook 'picture-mode-init)
(autoload 'picture-mode-init "picture-init")
(require 'picture)

(defun picture-mode-init ()
  (define-key picture-mode-map [C-right] 'picture-line-draw-right)
  (define-key picture-mode-map [C-left]  'picture-line-draw-left)
  (define-key picture-mode-map [C-up]    'picture-line-draw-up)
  (define-key picture-mode-map [C-down]  'picture-line-draw-down)
  (define-key picture-mode-map [A-right] 'picture-line-delete-right)
  (define-key picture-mode-map [A-left]  'picture-line-delete-left)
  (define-key picture-mode-map [A-up]    'picture-line-delete-up)
  (define-key picture-mode-map [A-down]  'picture-line-delete-down)
  (define-key picture-mode-map [M-right] 'picture-line-delete-right)
  (define-key picture-mode-map [M-left]  'picture-line-delete-left)
  (define-key picture-mode-map [M-up]    'picture-line-delete-up)
  (define-key picture-mode-map [M-down]  'picture-line-delete-down)
  (define-key picture-mode-map [(control ?c) C-right] 'picture-region-move-right)
  (define-key picture-mode-map [(control ?c) C-left]  'picture-region-move-left)
  (define-key picture-mode-map [(control ?c) C-up]    'picture-region-move-up)
  (define-key picture-mode-map [(control ?c) C-down]  'picture-region-move-down)
  nil)

(defun picture-line-draw-str (h v str)
  (cond ((/= h 0) (cond ((string= str "|") "+")
            ((string= str "+") "+")
            (t "-")))
    ((/= v 0) (cond ((string= str "-") "+")
            ((string= str "+") "+")
            (t "|")))
    (t str)
    ))

(defun picture-line-delete-str (h v str)
  (cond ((/= h 0) (cond ((string= str "|") "|")
            ((string= str "+") "|")
            (t " ")))
    ((/= v 0) (cond ((string= str "-") "-")
            ((string= str "+") "-")
            (t " ")))
    (t str)
    ))

(defun picture-line-draw (num v h del)
  (let ((indent-tabs-mode nil)
    (old-v picture-vertical-step)
    (old-h picture-horizontal-step))
    (setq picture-vertical-step v)
    (setq picture-horizontal-step h)
    ;; (setq picture-desired-column (current-column))
    (while (>= num 0)
      (when (= num 0)
    (setq picture-vertical-step 0)
    (setq picture-horizontal-step 0)
    )
      (setq num (1- num))
      (let (str new-str)
    (setq str
          (if (eobp) " " (buffer-substring (point) (+ (point) 1))))
    (setq new-str
          (if del (picture-line-delete-str h v str)
        (picture-line-draw-str h v str)))
    (picture-clear-column (string-width str))
    (picture-update-desired-column nil)
    (picture-insert (string-to-char new-str) 1)
    ))
    (setq picture-vertical-step old-v)
    (setq picture-horizontal-step old-h)
    ))

(defun picture-region-move (start end num v h)
  (let ((indent-tabs-mode nil)
    (old-v picture-vertical-step)
    (old-h picture-horizontal-step) rect)
    (setq picture-vertical-step v)
    (setq picture-horizontal-step h)
    (setq picture-desired-column (current-column))
    (setq rect (extract-rectangle start end))
    (clear-rectangle start end)
    (goto-char start)
    (picture-update-desired-column t)
    (picture-insert ?\  num)
    (picture-insert-rectangle rect nil)
    (setq picture-vertical-step old-v)
    (setq picture-horizontal-step old-h)
    ))
(defun picture-region-move-right (start end num)
  "Move a rectangle right."
  (interactive "r\np")
  (picture-region-move start end num 0 1))

(defun picture-region-move-left (start end num)
  "Move a rectangle left."
  (interactive "r\np")
  (picture-region-move start end num 0 -1))

(defun picture-region-move-up (start end num)
  "Move a rectangle up."
  (interactive "r\np")
  (picture-region-move start end num -1 0))

(defun picture-region-move-down (start end num)
  "Move a rectangle left."
  (interactive "r\np")
  (picture-region-move start end num 1 0))

(defun picture-line-draw-right (n)
  "Draw line right."
  (interactive "p")
  (picture-line-draw n 0 1 nil))

(defun picture-line-draw-left (n)
  "Draw line left."
  (interactive "p")
  (picture-line-draw n 0 -1 nil))

(defun picture-line-draw-up (n)
  "Draw line up."
  (interactive "p")
  (picture-line-draw n -1 0 nil))

(defun picture-line-draw-down (n)
  "Draw line down."
  (interactive "p")
  (picture-line-draw n 1 0 nil))

(defun picture-line-delete-right (n)
  "Delete line right."
  (interactive "p")
  (picture-line-draw n 0 1 t))

(defun picture-line-delete-left (n)
  "Delete line left."
  (interactive "p")
  (picture-line-draw n 0 -1 t))

(defun picture-line-delete-up (n)
  "Delete line up."
  (interactive "p")
  (picture-line-draw n -1 0 t))

(defun picture-line-delete-down (n)
  "Delete line down."
  (interactive "p")
  (picture-line-draw n 1 0 t))


;;;
;;; ETC
;;;


;; magit
;; VC(emacsのversion controlシステム)のままだとコマンド必須になるので入れる
;; もしかすると helm-gitにした方がいいかもしれない
;; projectile,helm-projectileとの関係上 magitはやめたほうがいいかも
;; (unless (require 'magit nil t) (package-install 'magit))
;; ;;;(unless (require 'magit-popup nil t) (package-install 'magit-popup))
;; (global-set-key (kbd "C-x m") 'magit-status)
;; ;;;ファイルが巨大だとgit brameがきれいに動かない VCのC-xvgは秀逸！
;; (defadvice vc-git-annotate-command (around vc-git-annotate-command activate)
;;   "suppress relative path of file from git blame output"
;;   (let ((name (file-relative-name file)))
;;     (vc-git-command buf 'async nil "blame" "--date=iso" rev "--" name)))
;; ;;(add-hook 'magit-mode-hook 'magit-svn-mode)
;; (define-key vc-prefix-map (kbd "l") 'magit-log-buffer-file-popup)

;;; ediff
;;; これがなければ意味が無いぐらい
(setq ediff-window-setup-function 'ediff-setup-windows-plain) ;コントロール用のバッファを同一フレーム内に表示
(setq ediff-split-window-function 'split-window-horizontally) ; diffのバッファを上下ではなく 左右に並べる

;;; undo tree
;;; undoを木構造で表示できる
;;; 問題点は C-?がwindowsのC-yのredoとはちょっと違うことあくまでundoの取り消しとしてのredo
;;; 繰り返しはキーボードマクロつかえということか。（redoまわりは今後調整する)
(unless (require 'undo-tree nil t) (package-install 'undo-tree))
(global-undo-tree-mode)
(define-key global-map (kbd "M-/") 'undo-tree-redo) ;; C-/ がundoの反対
;;(define-key undo-tree-map [return] 'undo-tree-visualizer-quit) ;; RETもquitにする qを押し忘れる なんか動きおかしい

;;; 操作系の基本設定
(show-paren-mode t)                  ; 対応する括弧を光らせる
(setq suggest-key-bindings t)        ; キーバインドの通知(登録されているキーが有るとき教えてくれる)
(fset 'yes-or-no-p 'y-or-n-p)        ; (yes/no) を (y/n)に
(define-key global-map (kbd "C-^") 'help-command) ; terminal接続時にはC-hがBSになるのでC-^をとっておく

;;; バックアップファイルを~/.emacs.d/backupへ(フォルダは作っておくこと)
(setq backup-directory-alist
      (cons (cons ".*" (expand-file-name "~/.emacs.d/backup")) backup-directory-alist)) ;バックアップ
(setq auto-save-file-name-transforms
      `((".*", (expand-file-name "~/.emacs.d/backup/") t))) ; 自動保存ファイル

;;;カーソル位置を記憶
;;; 一度 M-x toggle-save-placeを実行しないと動かない？
;;; enable saveplace
(if (and (>= emacs-major-version 24) (>= emacs-minor-version 5))
    (progn (require 'saveplace) (setq-default save-place t));; For GNU Emacs 24.5 and older versions.
  (save-place-mode 1)) ;; For GNU Emacs 25.1 and newer versions.

;;;プログラム記述系の共通設定
(setq-default indent-tabs-mode nil) ;; tabは使ない
(setq-default tab-width 2) ;; インデントは2文字
(add-hook 'before-save-hook 'delete-trailing-whitespace) ;;行末スペースをsave時に自動削除

;;; tab全角スペース可視化
(global-whitespace-mode 1)
(setq whitespace-space-regexp "\\(\u3000\\)")
(setq whitespace-style '(face tabs tab-mark spaces space-mark))
(setq whitespace-display-mappings ())
(set-face-foreground 'whitespace-tab "yellow")
(set-face-underline  'whitespace-tab t)
(set-face-foreground 'whitespace-space "yellow")
(set-face-background 'whitespace-space "red")
(set-face-underline  'whitespace-space t)

;;; smart-compile
;;; http://th.nao.ac.jp/MEMBER/zenitani/elisp-j.html#smart-compile
(unless (require 'smart-compile nil t) (package-install 'smart-compile))
;;;(global-set-key (kbd "C-c C-c") 'smart-compile)
(global-set-key (kbd "C-c c") 'smart-compile)
(define-key global-map [f5] (kbd "C-x C-s C-c c C-m"))
(define-key global-map [f6] 'next-error)
(global-set-key (kbd "C-c @") 'next-error)
(setq compilation-window-height 15)  ;; デフォルトは画面の下半分
(add-to-list 'smart-compile-alist '((expand-file-name "~/sptv/.*") . "cd ~/sptv/sptv_base;make func")) ;;ディレクトリごとにコンパイルコマンド変えるときこれ
(setq compilation-scroll-output t)

;;; js2-mode
;; https://qiita.com/sune2/items/e54bb5db129ae73d004b を見てもっと補完を頑張る nodejsでternサーバが必要（ポータビリティが落ちる）
(unless (require 'js2-mode nil t) (package-install 'js2-mode))
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(add-hook 'js2-mode-hook (lambda () (set (make-local-variable 'js2-indent-switch-body) t) )) ;;jsのcase文のインデントを通常へ
(setq js2-basic-offset 2) ;; js2modeのインデントを２へ

;;; web-mode js,css混在のソースをいじっている時に助かる
(unless (require 'web-mode nil t) (package-install 'web-mode))
(add-to-list 'auto-mode-alist '("\\.html?$"     . web-mode)) ;;; 適用する拡張子
(defun web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2))
(add-hook 'web-mode-hook 'web-mode-hook)

;;; eshell (emacs上のshell)
;;; 履歴と補完をhelmで行う
(add-hook 'eshell-mode-hook
          #'(lambda () (define-key eshell-mode-map (kbd "M-p") 'helm-eshell-history))) ;; helm で履歴から入力
(add-hook 'eshell-mode-hook
          #'(lambda () (define-key eshell-mode-map (kbd "M-n") 'helm-esh-pcomplete))) ;; helm で補完

;;; 以下はemacsが自動で設定したもの
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (mozc mozc-im mozc-popup color-moccur migemo web-mode undo-tree sr-speedbar magit js2-mode helm-descbinds helm-ag elscreen company))))

;; custom-set-fase は M-x customize-face で起動できる
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-preview-common ((t (:inherit company-preview :foreground "lightgrey"))))
 '(company-scrollbar-bg ((t (:background "gray40"))))
 '(company-scrollbar-fg ((t (:background "orange"))))
 '(company-tooltip ((t (:background "lightgrey" :foreground "black"))))
 '(company-tooltip-selection ((t (:background "steelblue")))))

;;; 自分関数
(defun my/copy-current-path ()
  "Copy the current buffer's file path or dired path to 'kill-ring'.Result is full path."
  (interactive)
  (let ((fPath (if (equal major-mode 'dired-mode) default-directory (buffer-file-name))))
    (when fPath
      (message "stored path: %s" fPath)
      (kill-new (file-truename fPath)))))
(global-set-key [C-f1] 'my/copy-current-path)
(define-key my-helm-map (kbd "p") 'my/copy-current-path)

;;; speedbarでhelm-ag
;;; 右ボタンメニューに入れられてない。
(defun my/speedbar-helm-ag ()
  "Execute helm ag on speedbar directory."
  (interactive)
  (helm-ag (speedbar-line-file)))

(define-key speedbar-file-key-map "G" 'my/speedbar-helm-ag)

;;; fill-paragraphをトグルにする
(defun toggle-fill-and-unfill ()
  "Toggle fill and unfill paragraph."
  (interactive)
  (let ((fill-column
         (if (eq last-command 'toggle-fill-and-unfill)
             (progn (setq this-command nil)
                    (point-max))
           fill-column)))
    (call-interactively #'fill-paragraph)))
(global-set-key [remap fill-paragraph] #'toggle-fill-and-unfill)


;;; dired で新しいバッファを開かないようにする
;; http://nishikawasasaki.hatenablog.com/entry/20120222/1329932699 を参考に dired-upを追加
;; https://qiita.com/ballforest/items/0ddbdfeaa9749647b488 でdiredを強化する予定
;; ファイルならelscreen上の別バッファで、ディレクトリなら同じバッファで開く
(defun dired-find-alternate-file2 ()
  "In Dired, visit this file or directory instead of the Dired buffer."
  (interactive)
  (set-buffer-modified-p nil)
  (let* ((dired-path (dired-get-file-for-visit))
         (dired-fname (file-name-nondirectory dired-path))
         (dired-dir (directory-file-name dired-path))
         (dired-path2 (cond ((string= dired-fname ".") dired-dir)
                            ((string= dired-fname "..") (directory-file-name dired-dir))
                            (t dired-path))))
    (find-alternate-file dired-path2)))
(defun dired-open-in-accordance-with-situation ()
  (interactive)
  (let ((file (dired-get-file-for-visit)))
    (if (file-directory-p file)
        (dired-find-alternate-file2)
      (let ((find-file-run-dired t)) (elscreen-find-file (dired-get-file-for-visit))))))
(defun dired-up-directory-open-in-accordance-with-situation ()
  "In Dired, visit up directory instead of the Dired buffer."
  (interactive)
  (let* ((dir (dired-current-directory))
         (up (file-name-directory (directory-file-name dir))))
    (or (dired-goto-file (directory-file-name dir)))
    (set-buffer-modified-p nil)
    (find-alternate-file up)))
(defun dired-mouse-find-file (event)
  "In Dired, visit the file or directory name you click on."
  (interactive "e")
  (let (window pos file)
    (save-excursion
      (setq window (posn-window (event-end event))
            pos (posn-point (event-end event)))
      (if (not (windowp window))
          (error "No file chosen"))
      (set-buffer (window-buffer window))
      (goto-char pos)
      (setq file (dired-get-file-for-visit)))
    (dired-open-in-accordance-with-situation)))
(define-key dired-mode-map [mouse-1] 'dired-mouse-find-file)
(put 'dired-find-alternate-file 'disabled nil) ;; dired-find-alternate-file の有効化
;; RET 標準の dired-find-file では dired バッファが複数作られるので
(define-key dired-mode-map (kbd "RET") 'dired-open-in-accordance-with-situation) ;; dired-find-alternate-file を代わりに使う
(define-key dired-mode-map (kbd "a") 'dired-find-file)
;; ディレクトリの移動キーを追加(wdired 中は無効)
(define-key dired-mode-map (kbd "<left>") 'dired-up-directory-open-in-accordance-with-situation)
(define-key dired-mode-map (kbd "<right>") 'dired-open-in-accordance-with-situation)
(define-key dired-mode-map (kbd "DEL") 'dired-up-directory-open-in-accordance-with-situation)
(put 'dired-find-alternate-file 'disabled nil)


;;; migemo
;;; 環境依存するのでとりあえずコメントアウト
;; (require 'migemo)
;; (setq migemo-dictionary "c:/Users/miyohiro/AppData/Roaming/.emacs.d/dict/cp932/migemo-dict")
;; ;;(setq migemo-dictionary "C:/Users/miyohiro/AppData/Roaming/.emacs.d/migemo/dict/cp932/migemo-dict")
;; ;;;(setq migemo-dictionary "C:/Users/username/AppData/Roaming/.emacs.d/conf/migemo/dict/utf-8/migemo-dict") ; 文字コードに注意.
;; (setq migemo-command "cmigemo")
;; (setq migemo-options '("-q" "--emacs" "-i" "\a")) (setq migemo-user-dictionary nil) (setq migemo-regex-dictionary nil)
;; ;;;(setq migemo-coding-system 'utf-8-unix) ; 文字コードに注意.
;; (setq migemo-coding-system 'cp932-unix)
;; (load-library "migemo") ; ロードパス指定.
;; (migemo-init)
;; (helm-migemo-mode 1) ;; occurでmigemoが使える


;;; やること
;;; http://sheephead.homelinux.org/2011/12/19/6930/
;;; https://github.com/magnars/multiple-cursors.el マルチ編集
;;; https://github.com/chikatoike/SublimeTextWiki/wiki/SublimeText-Vim-Emacs-%E3%83%97%E3%83%A9%E3%82%B0%E3%82%A4%E3%83%B3%E6%AF%94%E8%BC%83%E8%A1%A8 ここを参考に最強を目指すのだ

;;; js2mode拡充
;;; 実行中のchromeと通信し結果を得る https://github.com/NicolasPetton/Indium
;;; これも https://github.com/skeeto/skewer-mode


;;; 環境依存系の設定
;;; windowsのキーバインドをemacs化するには keyhacが使える
;;; http://qiita.com/hshimo/items/2f3f7e070ae75243eb8b

;;; terminalの時の設定
(when (eq window-system nil)
  (menu-bar-mode -1) ;; メニューバーを非表示
  (define-key global-map [select] 'end-of-line) ;;teraterm,rloginでendキーが効かないのでこれ入れておく

  ;;マウストラッキング
  ;; terminalでホイルスクロール、マウスクリックが使えるようになる。
  ;; 他のwindowとのコピペ時にはctrl押したり(teraterm),メニューで切り替えたりする必要あり(rlogin)
  (xterm-mouse-mode t)
  (mouse-wheel-mode t)
  (global-set-key [mouse-4] '(lambda () (interactive) (scroll-down 3)))
  (global-set-key [mouse-5] '(lambda () (interactive) (scroll-up   3)))
  )

;;; window-systemで立ち上がった時の設定
;;; http://hico-horiuchi.hateblo.jp/entry/20130415/1366010165 ; 分岐
(when window-system
  (progn
    (require 'linum)  ;;行番号表示
    (global-linum-mode t);; 常にlinum-modeを有効
    (unless (eq system-type 'darwin) ;; macじゃなかったら

      ;; font
      ;; http://qiita.com/melito/items/238bdf72237290bc6e42
      ;;; fc-cache -fv でキャッシュを行う
      (let* ((size 18)
             (asciifont "Ricty")
             (jpfont "Ricty")
             (h (* size 10))
             (fontspec (font-spec :family asciifont))
             (jp-fontspec (font-spec :family jpfont)))
        (set-face-attribute 'default nil :family asciifont :height h)
        (set-fontset-font nil 'japanese-jisx0213.2004-1 jp-fontspec)
        (set-fontset-font nil 'japanese-jisx0213-2 jp-fontspec)
        (set-fontset-font nil 'katakana-jisx0201 jp-fontspec)
        (set-fontset-font nil '(#x0080 . #x024F) fontspec)
        (set-fontset-font nil '(#x0370 . #x03FF) fontspec))

      ;; ずれ確認用
      ;; 0123456789012345678901234567890123456789
      ;; アイウエオアイウエオアイウエオアイウエオアイウエオアイウエオアイウエオアイウエオ
      ;; あいうえおあいうえおあいうえおあいうえお

        ;; mozcで入力
        ;;http://d.hatena.ne.jp/kitokitoki/20120925/p2
        ;; mozc-toolsを入れる
        ;;LANG=ja_JP.UTF-8  /usr/lib/mozc/mozc_tool -mode=config_dialog
        ;;https://yo.eki.do/notes/emacs-windows-2017
      (unless (require 'mozc nil t) (package-install 'mozc))
      (setq default-input-method "japanese-mozc")
        ;;(setq default-input-method "japanese-mozc")
      (define-key global-map [zenkaku-hankaku] 'toggle-input-method)


      (if (eq system-type 'gnu/linux) ;; linuxだったら
          (add-to-list 'default-frame-alist '(font . "ricty-13.5")) ;fontsize指定
        )
      (if (eq system-type 'windows-nt)  ;windowsだったら
          ;; http://blog.syati.info/post/make_windows_emacs/ ;windowsの設定はこのURLでOK
          ;; ショートカットで直接実行するとpathの設定がダメなので
          ;; これで実行するようにする  "C:\gnupack\startup_emacs.exe"
          (setq shell-file-name "bash")
        (setenv "SHELL" shell-file-name)
        (setq explicit-shell-file-name shell-file-name)
        )
      )
    ))
