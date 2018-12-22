;;; config/default/+bindings.el -*- lexical-binding: t; -*-

;; This file defines a Spacemacs-esque keybinding scheme

;; expand-region's prompt can't tell what key contract-region is bound to, so we
;; tell it explicitly.
(setq expand-region-contract-fast-key "V")


;;
;; Global keybindings

(map! (:map 'override
        ;; Make M-x more accessible
        "s-x"    'execute-extended-command
        "M-x"    'execute-extended-command
        ;; A little sandbox to run code in
        "s-;"    'eval-expression)

      [remap evil-jump-to-tag] #'projectile-find-tag
      [remap find-tag]         #'projectile-find-tag

      :i [remap newline] #'newline-and-indent
      :i "C-j"           #'+default/newline

      :n "s-+"    (λ! (text-scale-set 0))
      :n "s-="    #'text-scale-increase
      :n "s--"    #'text-scale-decrease

      ;; Simple window/frame navigation/manipulation
      :n "s-w"    #'delete-window
      :n "s-W"    #'delete-frame
      :n "C-S-f"  #'toggle-frame-fullscreen
      :n "s-n"    #'+default/new-buffer
      :n "s-N"    #'make-frame

      ;; Textmate-esque bindings
      :n "s-R"    #'+eval/region-and-replace
      :n "s-a"    #'mark-whole-buffer
      :n "s-b"    #'+default/compile
      :n "s-c"    #'evil-yank
      :n "s-f"    #'swiper
      :n "s-q"    (if (daemonp) #'delete-frame #'evil-quit-all)

      ;; expand-region
      :v "v"      #'er/expand-region
      :v "C-v"    #'er/contract-region

      ;; Restore OS undo, save, copy, & paste keys (without cua-mode, because it
      ;; imposes some other functionality and overhead we don't need)
      :g "s-z"    #'undo
      :g "s-s"    #'save-buffer
      :g "s-c"    #'yank
      :g "s-v"    #'copy-region-as-kill
      :v "s-v"    (if (featurep 'evil) #'evil-yank #'yank)

      :nv "C-SPC" #'+evil/fold-toggle)


;;
;; Built-in plugins

(map! :after vc-annotate
      :map vc-annotate-mode-map
      [remap quit-window #'kill-this-buffer])


;;
;; Module keybinds

;;; :feature
(map! (:when (featurep! :feature debugger)
        :after realgud
        :map realgud:shortkey-mode-map
        :n "j" #'evil-next-line
        :n "k" #'evil-previous-line
        :n "h" #'evil-backward-char
        :n "l" #'evil-forward-char
        :n "c" #'realgud:cmd-continue
        :m "n" #'realgud:cmd-next
        :m "b" #'realgud:cmd-break
        :m "B" #'realgud:cmd-clear)

      (:when (featurep! :feature eval)
        :g  "s-r" #'+eval/buffer
        :nv "gr"  #'+eval:region
        :n  "gR"  #'+eval/buffer
        :v  "gR"  #'+eval:replace-region)

      (:when (featurep! :feature evil)
        :m  "]a"    #'evil-forward-arg
        :m  "[a"    #'evil-backward-arg
        :m  "]o"    #'outline-next-visible-heading
        :m  "[o"    #'outline-previous-visible-heading
        :n  "]b"    #'next-buffer
        :n  "[b"    #'previous-buffer
        :n  "zx"    #'kill-this-buffer
        :n  "ZX"    #'bury-buffer
        :n  "gp"    #'+evil/reselect-paste
        :nv "g="    #'widen
        :nv "g-"    #'+evil:narrow-buffer
        :nv "g@"    #'+evil:apply-macro
        :nv "gc"    #'evil-commentary
        :nv "gx"    #'evil-exchange
        :nv "C-a"   #'evil-numbers/inc-at-pt
        :nv "C-S-a" #'evil-numbers/dec-at-pt
        :nv [tab]   #'+evil/matchit-or-toggle-fold
        :v  "gp"    #'+evil/paste-preserve-register
        :v  "@"     #'+evil:apply-macro
        ;; repeat in visual mode (FIXME buggy)
        :v  "."     #'+evil:apply-macro
        ;; don't leave visual mode after shifting
        :v  "<"     #'+evil/visual-dedent  ; vnoremap < <gv
        :v  ">"     #'+evil/visual-indent  ; vnoremap > >gv

        ;; window management (prefix "C-w")
        (:map evil-window-map
          ;; Navigation
          "C-h"     #'evil-window-left
          "C-j"     #'evil-window-down
          "C-k"     #'evil-window-up
          "C-l"     #'evil-window-right
          "C-w"     #'other-window
          ;; Swapping windows
          "H"       #'+evil/window-move-left
          "J"       #'+evil/window-move-down
          "K"       #'+evil/window-move-up
          "L"       #'+evil/window-move-right
          "C-S-w"   #'ace-swap-window
          ;; Window undo/redo
          "u"       #'winner-undo
          "C-u"     #'winner-undo
          "C-r"     #'winner-redo
          "o"       #'doom/window-enlargen
          "O"       #'doom/window-zoom
          ;; Delete window
          "c"       #'+workspace/close-window-or-workspace
          "C-C"     #'ace-delete-window)

        ;; Plugins
        ;; evil-easymotion
        :m  "gs"    #'+evil/easymotion  ; lazy-load `evil-easymotion'
        (:after evil-easymotion
          :map evilem-map
          "a" (evilem-create #'evil-forward-arg)
          "A" (evilem-create #'evil-backward-arg)
          "s" (evilem-create #'evil-snipe-repeat
                             :name 'evil-easymotion-snipe-forward
                             :pre-hook (save-excursion (call-interactively #'evil-snipe-s))
                             :bind ((evil-snipe-scope 'buffer)
                                    (evil-snipe-enable-highlight)
                                    (evil-snipe-enable-incremental-highlight)))
          "S" (evilem-create #'evil-snipe-repeat
                             :name 'evil-easymotion-snipe-backward
                             :pre-hook (save-excursion (call-interactively #'evil-snipe-S))
                             :bind ((evil-snipe-scope 'buffer)
                                    (evil-snipe-enable-highlight)
                                    (evil-snipe-enable-incremental-highlight)))
          "SPC" #'avy-goto-char-timer
          "/" (evilem-create #'evil-ex-search-next
                             :pre-hook (save-excursion (call-interactively #'evil-ex-search-forward))
                             :bind ((evil-search-wrap)))
          "?" (evilem-create #'evil-ex-search-previous
                             :pre-hook (save-excursion (call-interactively #'evil-ex-search-backward))
                             :bind ((evil-search-wrap))))

        ;; text object plugins
        :textobj "x" #'evil-inner-xml-attr               #'evil-outer-xml-attr
        :textobj "a" #'evil-inner-arg                    #'evil-outer-arg
        :textobj "B" #'evil-textobj-anyblock-inner-block #'evil-textobj-anyblock-a-block
        :textobj "i" #'evil-indent-plus-i-indent         #'evil-indent-plus-a-indent
        :textobj "k" #'evil-indent-plus-i-indent-up      #'evil-indent-plus-a-indent-up
        :textobj "j" #'evil-indent-plus-i-indent-up-down #'evil-indent-plus-a-indent-up-down

        ;; evil-snipe
        (:after evil-snipe
          :map evil-snipe-parent-transient-map
          "C-;" (λ! (require 'evil-easymotion)
                    (call-interactively
                     (evilem-create #'evil-snipe-repeat
                                    :bind ((evil-snipe-scope 'whole-buffer)
                                           (evil-snipe-enable-highlight)
                                           (evil-snipe-enable-incremental-highlight))))))

        ;; evil-surround
        :v  "S"     #'evil-surround-region
        :o  "s"     #'evil-surround-edit
        :g  "S"     #'evil-Surround-edit)

      (:when (featurep! :feature lookup)
        :nv "K"  #'+lookup/documentation
        :nv "gd" #'+lookup/definition
        :nv "gD" #'+lookup/references
        :nv "gf" #'+lookup/file)

      (:when (featurep! :feature snippets)
        ;; auto-yasnippet
        :i  [C-tab] #'aya-expand
        :nv [C-tab] #'aya-create
        ;; yasnippet
        (:after yasnippet
          (:map yas-keymap
            "C-e"           #'+snippets/goto-end-of-field
            "C-a"           #'+snippets/goto-start-of-field
            "<s-right>"     #'+snippets/goto-end-of-field
            "<s-left>"      #'+snippets/goto-start-of-field
            "<s-backspace>" #'+snippets/delete-to-start-of-field
            [backspace]     #'+snippets/delete-backward-char
            [delete]        #'+snippets/delete-forward-char-or-field)
          (:map yas-minor-mode-map
            :ie [tab] yas-maybe-expand
            :v  [tab] #'yas-insert-snippet)))

      (:when (featurep! :feature spellcheck)
        :m "]S" #'flyspell-correct-word-generic
        :m "[S" #'flyspell-correct-previous-word-generic
        (:map flyspell-mouse-map
          "RET"     #'flyspell-correct-word-generic
          [mouse-1] #'flyspell-correct-word-generic))

      (:when (featurep! :completion syntax-checker)
        :m "]e" #'next-error
        :m "[e" #'previous-error
        (:after flycheck
          :map flycheck-error-list-mode-map
          :n "C-n" #'flycheck-error-list-next-error
          :n "C-p" #'flycheck-error-list-previous-error
          :n "j"   #'flycheck-error-list-next-error
          :n "k"   #'flycheck-error-list-previous-error
          :n "RET" #'flycheck-error-list-goto-error))

      (:when (featurep! :feature workspaces)
        :n "s-t" #'+workspace/new
        :n "s-T" #'+workspace/display
        :n "s-1" (λ! (+workspace/switch-to 0))
        :n "s-2" (λ! (+workspace/switch-to 1))
        :n "s-3" (λ! (+workspace/switch-to 2))
        :n "s-4" (λ! (+workspace/switch-to 3))
        :n "s-5" (λ! (+workspace/switch-to 4))
        :n "s-6" (λ! (+workspace/switch-to 5))
        :n "s-7" (λ! (+workspace/switch-to 6))
        :n "s-8" (λ! (+workspace/switch-to 7))
        :n "s-9" (λ! (+workspace/switch-to 8))
        :n "s-0" #'+workspace/switch-to-last
        :n "gt"  #'+workspace/switch-right
        :n "gT"  #'+workspace/switch-left
        :n "]w"  #'+workspace/switch-right
        :n "[w"  #'+workspace/switch-left))

;;; :completion
(map! (:when (featurep! :completion company)
        :i  "C-@"   #'+company/complete
        :i  "C-SPC" #'+company/complete
        (:prefix "C-x"
          :i "C-l"  #'+company/whole-lines
          :i "C-k"  #'+company/dict-or-keywords
          :i "C-f"  #'company-files
          :i "C-]"  #'company-etags
          :i "s"    #'company-ispell
          :i "C-s"  #'company-yasnippet
          :i "C-o"  #'company-capf
          :i "C-n"  #'+company/dabbrev
          :i "C-p"  #'+company/dabbrev-code-previous)
        (:after company
          (:map company-active-map
            "C-w"     nil  ; don't interfere with `evil-delete-backward-word'
            "C-n"     #'company-select-next
            "C-p"     #'company-select-previous
            "C-j"     #'company-select-next
            "C-k"     #'company-select-previous
            "C-h"     #'company-show-doc-buffer
            "C-u"     #'company-previous-page
            "C-d"     #'company-next-page
            "C-s"     #'company-filter-candidates
            "C-S-s"   `(,(cond ((featurep! :completion helm) #'helm-company)
                               ((featurep! :completion ivy)  #'counsel-company)))
            "C-SPC"   #'company-complete-common
            [tab]     #'company-complete-common-or-cycle
            [backtab] #'company-select-previous)
          (:map company-search-map  ; applies to `company-filter-map' too
            "C-n"     #'company-select-next-or-abort
            "C-p"     #'company-select-previous-or-abort
            "C-j"     #'company-select-next-or-abort
            "C-k"     #'company-select-previous-or-abort
            "C-s"     (λ! (company-search-abort) (company-filter-candidates))
            [escape]  #'company-search-abort)
          ;; TAB auto-completion in term buffers
          :map comint-mode-map [tab] #'company-complete))

      (:when (featurep! :completion ivy)
        (:map (help-mode-map helpful-mode-map)
          :n "Q" #'ivy-resume)
        (:after ivy
          :map ivy-minibuffer-map
          "C-SPC" #'ivy-call-and-recenter  ; preview file
          "C-l"   #'ivy-alt-done
          "s-z"   #'undo
          "s-v"   #'yank
          "C-v"   #'yank)
        (:after counsel
          :map counsel-ag-map
          [backtab]  #'+ivy/wgrep-occur      ; search/replace on results
          "C-SPC"    #'ivy-call-and-recenter ; preview
          "s-RET"    (+ivy-do-action! #'+ivy-git-grep-other-window-action))
        (:after swiper
          :map swiper-map
          [backtab] #'+ivy/wgrep-occur))

      (:when (featurep! :completion helm)
        (:after helm
          (:map helm-map
            [left]     #'left-char
            [right]    #'right-char
            "C-S-n"    #'helm-next-source
            "C-S-p"    #'helm-previous-source
            "C-j"      #'helm-next-line
            "C-k"      #'helm-previous-line
            "C-S-j"    #'helm-next-source
            "C-S-k"    #'helm-previous-source
            "C-f"      #'helm-next-page
            "C-S-f"    #'helm-previous-page
            "C-u"      #'helm-delete-minibuffer-contents
            "C-w"      #'backward-kill-word
            "C-r"      #'evil-paste-from-register ; Evil registers in helm! Glorious!
            "C-s"      #'helm-minibuffer-history
            "C-b"      #'backward-word
            ;; Swap TAB and C-z
            [tab]      #'helm-execute-persistent-action
            "C-z"      #'helm-select-action)
          (:after swiper-helm
            :map swiper-helm-keymap [backtab] #'helm-ag-edit)
          (:after helm-ag
            :map helm-ag-map
            "C--"      #'+helm-do-ag-decrease-context
            "C-="      #'+helm-do-ag-increase-context
            [backtab]  #'helm-ag-edit
            [left] nil
            [right] nil)
          (:after helm-files
            :map (helm-find-files-map helm-read-file-map)
            [M-return] #'helm-ff-run-switch-other-window
            "C-w"      #'helm-find-files-up-one-level)
          (:after helm-locate
            :map helm-generic-files-map [M-return] #'helm-ff-run-switch-other-window)
          (:after helm-buffers
            :map helm-buffer-map [M-return] #'helm-buffer-switch-other-window)
          (:after helm-regexp
            :map helm-moccur-map [M-return] #'helm-moccur-run-goto-line-ow)
          (:after helm-grep
            :map helm-grep-map [M-return] #'helm-grep-run-other-window-action))))

;;; :ui
(map! (:when (featurep! :ui hl-todo)
        :m "]t" #'hl-todo-next
        :m "[t" #'hl-todo-previous)

      (:when (featurep! :ui neotree)
        :after neotree
        :map neotree-mode-map
        :n "g"         nil
        :n [tab]       #'neotree-quick-look
        :n "RET"       #'neotree-enter
        :n [backspace] #'evil-window-prev
        :n "c"         #'neotree-create-node
        :n "r"         #'neotree-rename-node
        :n "d"         #'neotree-delete-node
        :n "j"         #'neotree-next-line
        :n "k"         #'neotree-previous-line
        :n "n"         #'neotree-next-line
        :n "p"         #'neotree-previous-line
        :n "h"         #'+neotree/collapse-or-up
        :n "l"         #'+neotree/expand-or-open
        :n "J"         #'neotree-select-next-sibling-node
        :n "K"         #'neotree-select-previous-sibling-node
        :n "H"         #'neotree-select-up-node
        :n "L"         #'neotree-select-down-node
        :n "G"         #'evil-goto-line
        :n "gg"        #'evil-goto-first-line
        :n "v"         #'neotree-enter-vertical-split
        :n "s"         #'neotree-enter-horizontal-split
        :n "q"         #'neotree-hide
        :n "R"         #'neotree-refresh)

      (:when (featurep! :ui popup)
        :n "C-`"   #'+popup/toggle
        :n "C-~"   #'+popup/raise
        :g "C-x p" #'+popup/other)

      (:when (featurep! :ui vc-gutter)
        :m "]d"    #'git-gutter:next-hunk
        :m "[d"    #'git-gutter:previous-hunk))

;;; :editor
(map! (:when (featurep! :editor format)
        :n "gQ"    #'+format:region)

      (:when (featurep! :editor multiple-cursors)
        ;; evil-mc
        (:prefix "gz"
          :nv "d" #'evil-mc-make-and-goto-next-match
          :nv "D" #'evil-mc-make-and-goto-prev-match
          :nv "j" #'evil-mc-make-cursor-move-next-line
          :nv "k" #'evil-mc-make-cursor-move-prev-line
          :nv "m" #'evil-mc-make-all-cursors
          :nv "n" #'evil-mc-make-and-goto-next-cursor
          :nv "N" #'evil-mc-make-and-goto-last-cursor
          :nv "p" #'evil-mc-make-and-goto-prev-cursor
          :nv "P" #'evil-mc-make-and-goto-first-cursor
          :nv "t" #'+evil/mc-toggle-cursors
          :nv "u" #'evil-mc-undo-all-cursors
          :nv "z" #'+evil/mc-make-cursor-here)
        (:after evil-mc
          :map evil-mc-key-map
          :nv "C-n" #'evil-mc-make-and-goto-next-cursor
          :nv "C-N" #'evil-mc-make-and-goto-last-cursor
          :nv "C-p" #'evil-mc-make-and-goto-prev-cursor
          :nv "C-P" #'evil-mc-make-and-goto-first-cursor)
        ;; evil-multiedit
        :v  "R"     #'evil-multiedit-match-all
        :n  "M-d"   #'evil-multiedit-match-symbol-and-next
        :n  "M-D"   #'evil-multiedit-match-symbol-and-prev
        :v  "M-d"   #'evil-multiedit-match-and-next
        :v  "M-D"   #'evil-multiedit-match-and-prev
        :nv "C-M-d" #'evil-multiedit-restore
        (:after evil-multiedit
          (:map evil-multiedit-state-map
            "M-d" #'evil-multiedit-match-and-next
            "M-D" #'evil-multiedit-match-and-prev
            "RET" #'evil-multiedit-toggle-or-restrict-region)
          (:map (evil-multiedit-state-map evil-multiedit-insert-state-map)
            "C-n" #'evil-multiedit-next
            "C-p" #'evil-multiedit-prev)))

      (:when (featurep! :editor rotate-text)
        :n "!" #'rotate-text))

;;; :emacs
(map! (:when (featurep! :emacs vc)
        :after git-timemachine
        :map git-timemachine-mode-map
        :n "C-p" #'git-timemachine-show-previous-revision
        :n "C-n" #'git-timemachine-show-next-revision
        :n "[["  #'git-timemachine-show-previous-revision
        :n "]]"  #'git-timemachine-show-next-revision
        :n "q"   #'git-timemachine-quit
        :n "gb"  #'git-timemachine-blame))

;;; :tools
(map! (:when (featurep! :tools magit)
        :after evil-magit
        ;; fix conflicts with private bindings
        :map (magit-status-mode-map magit-revision-mode-map)
        "C-j" nil
        "C-k" nil)

      (:when (featurep! :tools gist)
        :after gist
        :map gist-list-menu-mode-map
        :n "RET" #'+gist/open-current
        :n "b"   #'gist-browse-current-url
        :n "c"   #'gist-add-buffer
        :n "d"   #'gist-kill-current
        :n "f"   #'gist-fork
        :n "q"   #'quit-window
        :n "r"   #'gist-list-reload
        :n "s"   #'gist-star
        :n "S"   #'gist-unstar
        :n "y"   #'gist-print-current-url))

;;; :lang
(map! (:when (featurep! :lang markdown)
        :after markdown-mode
        :map markdown-mode-map
        ;; fix conflicts with private bindings
        "<backspace>" nil
        "<s-left>" nil
        "<s-right>" nil))


;;
;; <leader>

(map! :leader
      :desc "Ex Command"            ";"    #'evil-ex
      :desc "M-x"                   ":"    #'execute-extended-command
      :desc "Pop up scratch buffer" "x"    #'doom/open-scratch-buffer
      :desc "Org Capture"           "X"    #'org-capture

      ;; C-u is used by evil
      :desc "Universal argument"    "u"    #'universal-argument
      :desc "Window management"     "w"    #'evil-window-map

      :desc "Toggle last popup"     "~"    #'+popup/toggle
      :desc "Find file"             "."    #'find-file
      :desc "Switch to buffer"      ","    #'switch-to-buffer

      :desc "Resume last search"    "'"
      (cond ((featurep! :completion ivy)   #'ivy-resume)
            ((featurep! :completion helm)  #'helm-resume))

      :desc "Find file in project"  "SPC"  #'projectile-find-file
      :desc "Blink cursor line"     "DEL"  #'+nav-flash/blink-cursor
      :desc "Jump to bookmark"      "RET"  #'bookmark-jump

      ;; Prefixed key groups
      (:prefix ("/" . "search")
        :desc "Jump to symbol across buffers" "I" #'imenu-anywhere
        :desc "Search buffer"                 "b" #'swiper
        :desc "Search current directory"      "d" #'+ivy/project-search-from-cwd
        :desc "Jump to symbol"                "i" #'imenu
        :desc "Jump to link"                  "l" #'ace-link
        :desc "Look up online"                "o" #'+lookup/online-select
        :desc "Search project"                "p" #'+ivy/project-search)

      (:prefix ("]" . "next")
        :desc "Increase text size"          "["  #'text-scale-decrease
        :desc "Next buffer"                 "b"  #'previous-buffer
        :desc "Next diff Hunk"              "d"  #'git-gutter:previous-hunk
        :desc "Next todo"                   "t"  #'hl-todo-previous
        :desc "Next error"                  "e"  #'previous-error
        :desc "Next workspace"              "w"  #'+workspace/switch-left
        :desc "Next spelling error"         "s"  #'evil-prev-flyspell-error
        :desc "Next spelling correction"    "S"  #'flyspell-correct-previous-word-generic)

      (:prefix ("[" . "previous")
        :desc "Text size"                   "]"  #'text-scale-increase
        :desc "Buffer"                      "b"  #'next-buffer
        :desc "Diff Hunk"                   "d"  #'git-gutter:next-hunk
        :desc "Todo"                        "t"  #'hl-todo-next
        :desc "Error"                       "e"  #'next-error
        :desc "Workspace"                   "w"  #'+workspace/switch-right
        :desc "Spelling error"              "s"  #'evil-next-flyspell-error
        :desc "Spelling correction"         "S"  #'flyspell-correct-word-generic)

      (:when (featurep! :feature workspaces)
        (:prefix ("TAB" . "workspace")
          :desc "Display tab bar"           "TAB" #'+workspace/display
          :desc "New workspace"             "n"   #'+workspace/new
          :desc "Load workspace from file"  "l"   #'+workspace/load
          :desc "Load a past session"       "L"   #'+workspace/load-session
          :desc "Save workspace to file"    "s"   #'+workspace/save
          :desc "Autosave current session"  "S"   #'+workspace/save-session
          :desc "Switch workspace"          "."   #'+workspace/switch-to
          :desc "Delete session"            "x"   #'+workspace/kill-session
          :desc "Delete this workspace"     "d"   #'+workspace/delete
          :desc "Rename workspace"          "r"   #'+workspace/rename
          :desc "Restore last session"      "R"   #'+workspace/load-last-session
          :desc "Next workspace"            "]"   #'+workspace/switch-right
          :desc "Previous workspace"        "["   #'+workspace/switch-left
          :desc "Switch to 1st workspace"   "1"   (λ! (+workspace/switch-to 0))
          :desc "Switch to 2nd workspace"   "2"   (λ! (+workspace/switch-to 1))
          :desc "Switch to 3rd workspace"   "3"   (λ! (+workspace/switch-to 2))
          :desc "Switch to 4th workspace"   "4"   (λ! (+workspace/switch-to 3))
          :desc "Switch to 5th workspace"   "5"   (λ! (+workspace/switch-to 4))
          :desc "Switch to 6th workspace"   "6"   (λ! (+workspace/switch-to 5))
          :desc "Switch to 7th workspace"   "7"   (λ! (+workspace/switch-to 6))
          :desc "Switch to 8th workspace"   "8"   (λ! (+workspace/switch-to 7))
          :desc "Switch to 9th workspace"   "9"   (λ! (+workspace/switch-to 8))
          :desc "Switch to last workspace"  "0"   #'+workspace/switch-to-last))

      (:prefix ("b" . "buffer")
        :desc "Toggle narrowing"            "-"   #'doom/clone-and-narrow-buffer
        :desc "New empty buffer"            "N"   #'evil-buffer-new
        :desc "Sudo edit this file"         "S"   #'doom/sudo-this-file
        :desc "Previous buffer"             "["   #'previous-buffer
        :desc "Next buffer"                 "]"   #'next-buffer
        :desc "Switch buffer"               "b"   #'switch-to-buffer
        :desc "Kill buffer"                 "k"   #'kill-this-buffer
        :desc "Next buffer"                 "n"   #'next-buffer
        :desc "Kill other buffers"          "o"   #'doom/kill-other-buffers
        :desc "Previous buffer"             "p"   #'previous-buffer
        :desc "Save buffer"                 "s"   #'save-buffer
        :desc "Pop scratch buffer"          "x"   #'doom/open-scratch-buffer
        :desc "Bury buffer"                 "z"   #'bury-buffer)

      (:prefix ("c" . "code")
        :desc "Jump to references"          "D"   #'+lookup/references
        :desc "Evaluate & replace region"   "E"   #'+eval:replace-region
        :desc "Delete trailing newlines"    "W"   #'doom/delete-trailing-newlines
        :desc "Build tasks"                 "b"   #'+eval/build
        :desc "Jump to definition"          "d"   #'+lookup/definition
        :desc "Evaluate buffer/region"      "e"   #'+eval/buffer-or-region
        :desc "Format buffer/region"        "f"   #'+format/region-or-buffer
        :desc "Open REPL"                   "r"   #'+eval/open-repl
        :desc "Delete trailing whitespace"  "w"   #'delete-trailing-whitespace
        :desc "List errors"                 "x"   #'flycheck-list-errors)

      (:prefix ("f" . "file")
        :desc "Find file"                   "."   #'find-file
        :desc "Find file in project"        "/"   #'projectile-find-file
        :desc "Sudo find file"              ">"   #'doom/sudo-find-file
        :desc "Find file from here"         "?"   #'counsel-file-jump
        :desc "Browse emacs.d"              "E"   #'+default/browse-emacsd
        :desc "Browse private config"       "P"   #'+default/browse-config
        :desc "Recent project files"        "R"   #'projectile-recentf
        :desc "Delete this file"            "X"   #'doom/delete-this-file
        :desc "Find other file"             "a"   #'projectile-find-other-file
        :desc "Open project editorconfig"   "c"   #'editorconfig-find-current-editorconfig
        :desc "Find directory"              "d"   #'dired
        :desc "Find file in emacs.d"        "e"   #'+default/find-in-emacsd
        :desc "Find file in private config" "p"   #'+default/find-in-config
        :desc "Recent files"                "r"   #'recentf-open-files
        :desc "Save file"                   "s"   #'save-buffer
        :desc "Yank filename"               "y"   #'+default/yank-buffer-filename)

      (:prefix ("g" . "git")
        (:when (featurep! :ui vc-gutter)
          :desc "Git revert hunk"             "r"   #'git-gutter:revert-hunk
          :desc "Git stage hunk"              "s"   #'git-gutter:stage-hunk
          :desc "Git time machine"            "t"   #'git-timemachine-toggle
          :desc "Next hunk"                   "]"   #'git-gutter:next-hunk
          :desc "Previous hunk"               "["   #'git-gutter:previous-hunk)
        (:when (featurep! :emacs vc)
          :desc "Browse issues tracker"       "I"   #'+vc/git-browse-issues
          :desc "Browse remote"               "o"   #'+vc/git-browse
          :desc "Git revert file"             "R"   #'vc-revert)
        (:when (featurep! :tools magit)
          :desc "Magit blame"                 "b"   #'magit-blame-addition
          :desc "Magit commit"                "c"   #'magit-commit
          :desc "Magit clone"                 "C"   #'+magit/clone
          :desc "Magit dispatch"              "d"   #'magit-dispatch-popup
          :desc "Magit find-file"             "f"   #'magit-find-file
          :desc "Magit status"                "g"   #'magit-status
          :desc "Magit file delete"           "x"   #'magit-file-delete
          :desc "MagitHub dispatch"           "h"   #'magithub-dispatch-popup
          :desc "Initialize repo"             "i"   #'magit-init
          :desc "Magit buffer log"            "l"   #'magit-log-buffer-file
          :desc "List repositories"           "L"   #'magit-list-repositories
          :desc "Git stage file"              "S"   #'magit-stage-file
          :desc "Git unstage file"            "U"   #'magit-unstage-file
          :desc "Magit push popup"            "p"   #'magit-push-popup
          :desc "Magit pull popup"            "P"   #'magit-pull-popup)
        (:when (featurep! :tools gist)
          :desc "List gists"                  "G"   #'+gist:list))

      (:prefix ("h" . "help")
        :desc "What face"                     "'"   #'doom/what-face
        :desc "Describe at point"             "."   #'helpful-at-point
        :desc "Describe active minor modes"   ";"   #'doom/describe-active-minor-mode
        :desc "Open Doom manual"              "D"   #'doom/open-manual
        :desc "Open vanilla sandbox"          "E"   #'doom/open-vanilla-sandbox
        :desc "Describe face"                 "F"   #'describe-face
        :desc "Find documentation"            "K"   #'+lookup/documentation
        :desc "Command log"                   "L"   #'global-command-log-mode
        :desc "Describe mode"                 "M"   #'describe-mode
        :desc "Reload private config"         "R"   #'doom/reload
        :desc "Print Doom version"            "V"   #'doom/version
        :desc "Apropos"                       "a"   #'apropos
        :desc "Open Bug Report"               "b"   #'doom/open-bug-report
        :desc "Describe char"                 "c"   #'describe-char
        :desc "Describe DOOM module"          "d"   #'doom/describe-module
        :desc "Describe function"             "f"   #'describe-function
        :desc "Emacs help map"                "h"   help-map
        :desc "Info"                          "i"   #'info-lookup-symbol
        :desc "Describe key"                  "k"   #'describe-key
        :desc "Find library"                  "l"   #'find-library
        :desc "View *Messages*"               "m"   #'view-echo-area-messages
        :desc "Toggle profiler"               "p"   #'doom/toggle-profiler
        :desc "Reload theme"                  "r"   #'doom/reload-theme
        :desc "Describe DOOM setting"         "s"   #'doom/describe-setters
        :desc "Describe variable"             "v"   #'describe-variable
        :desc "Man pages"                     "w"   #'+default/man-or-woman)

      (:prefix ("i" . "insert")
        :desc "Insert from clipboard"         "y"   #'yank-pop
        :desc "Insert from evil register"     "r"   #'evil-ex-registers
        :desc "Insert snippet"                "s"   #'yas-insert-snippet)

      (:prefix ("n" . "notes")
        "d"   (if (featurep! :ui deft) #'deft)
        "n"   '(+default/find-in-notes :wk "Find file in notes")
        "N"   '(+default/browse-notes  :wk "Browse notes")
        "x"   '(org-capture            :wk "Org capture"))

      (:prefix ("o" . "open")
        :desc "Org agenda"        "a"  #'org-agenda
        :desc "Default browser"   "b"  #'browse-url-of-file
        :desc "Debugger"          "d"  #'+debug/open
        :desc "REPL"              "r"  #'+eval/open-repl
        :desc "Dired"             "-"  #'dired-jump
        (:when (featurep! :ui neotree)
          :desc "Project sidebar"              "p" #'+neotree/open
          :desc "Find file in project sidebar" "P" #'+neotree/find-this-file)
        (:when (featurep! :ui treemacs)
          :desc "Project sidebar" "p" #'+treemacs/toggle
          :desc "Find file in project sidebar" "P" #'+treemacs/find-file)
        (:when (featurep! :emacs imenu)
          :desc "Imenu sidebar" "i" #'imenu-list-smart-toggle)
        (:when (featurep! :emacs term)
          :desc "Terminal"          "t" #'+term/open
          :desc "Terminal in popup" "T" #'+term/open-popup-in-project)
        (:when (featurep! :emacs eshell)
          :desc "Eshell"            "e" #'+eshell/open
          :desc "Eshell in popup"   "E" #'+eshell/open-popup)
        (:when (featurep! :collab floobits)
          (:prefix ("f" . "floobits")
            "c" #'floobits-clear-highlights
            "f" #'floobits-follow-user
            "j" #'floobits-join-workspace
            "l" #'floobits-leave-workspace
            "R" #'floobits-share-dir-private
            "s" #'floobits-summon
            "t" #'floobits-follow-mode-toggle
            "U" #'floobits-share-dir-public))
        (:when (featurep! :tools macos)
          :desc "Reveal in Finder"           "o" #'+macos/reveal-in-finder
          :desc "Reveal project in Finder"   "O" #'+macos/reveal-project-in-finder
          :desc "Send to Transmit"           "u" #'+macos/send-to-transmit
          :desc "Send project to Transmit"   "U" #'+macos/send-project-to-transmit
          :desc "Send to Launchbar"          "l" #'+macos/send-to-launchbar
          :desc "Send project to Launchbar"  "L" #'+macos/send-project-to-launchbar)
        (:when (featurep! :tools docker)
          :desc "Docker" "D" #'docker))

      ;; (:prefix ("p" . "project")
      ;;   "."   '(+default/browse-project              :wk "Browse project")
      ;;   "/"   '(projectile-find-file                 :wk "Find file in project")
      ;;   "!"   '(projectile-run-shell-command-in-root :wk "Run cmd in project root")
      ;;   "c"   '(projectile-compile-project           :wk "Compile project")
      ;;   "o"   '(projectile-find-other-file           :wk "Find other file")
      ;;   "p"   '(projectile-switch-project            :wk "Switch project")
      ;;   "r"   '(projectile-recentf                   :wk "Recent project files")
      ;;   "t"   '(+ivy/tasks                           :wk "List project tasks")
      ;;   "x"   '(projectile-invalidate-cache          :wk "Invalidate cache"))

      ;; (:prefix ("q" . "quit/restart")
      ;;   "q"   '(evil-quit-all                         :wk "Quit Emacs")
      ;;   "Q"   '(evil-save-and-quit                    :wk "Save and quit Emacs")
      ;;   "X"   '(+workspace/kill-session-and-quit      :wk "Quit Emacs & forget session")
      ;;   "r"   '(+workspace/restart-emacs-then-restore :wk "Restart & restore Emacs")
      ;;   "R"   '(restart-emacs                         :wk "Restart Emacs"))

      ;; (:when (featurep! :tools upload)
      ;;   (:prefix ("r" . "remote")
      ;;     "u" '(ssh-deploy-upload-handler :wk "Upload local")
      ;;     "U" '(ssh-deploy-upload-handler-forced :wk "Upload local (force)")
      ;;     "d" '(ssh-deploy-download-handler :wk "Download remote")
      ;;     "D" '(ssh-deploy-diff-handler :wk "Diff local & remote")
      ;;     "." '(ssh-deploy-browse-remote-handler :wk "Browse remote files")
      ;;     ">" '(ssh-deploy-remote-changes-handler :wk "Detect remote changes")))

      ;; (:when (featurep! :feature snippets)
      ;;   (:prefix ("s" . "snippets")
      ;;     "n" '(yas-new-snippet :wk "New snippet")
      ;;     "i" '(yas-insert-snippet :wk "Insert snippet")
      ;;     "/" '(yas-visit-snippet-file :wk "Jump to mode snippet")
      ;;     "s" '(+snippets/find-file :wk "Jump to snippet")
      ;;     "S" '(+snippets/browse :wk "Browse snippets")
      ;;     "r" '(yas-reload-all :wk "Reload snippets")))

      ;; (:prefix ("t" . "toggle")
      ;;   "s"   '(flyspell-mode                             :wk "Flyspell")
      ;;   "f"   '(flycheck-mode                             :wk "Flycheck")
      ;;   "l"   '(doom/toggle-line-numbers                  :wk "Line numbers")
      ;;   "F"   '(toggle-frame-fullscreen                   :wk "Frame fullscreen")
      ;;   "i"   '(highlight-indentation-mode                :wk "Indent guides")
      ;;   "I"   '(highlight-indentation-current-column-mode :wk "Indent guides (column)")
      ;;   "h"   '(+impatient-mode/toggle                    :wk "Impatient mode")
      ;;   "b"   '(doom-big-font-mode                        :wk "Big mode")
      ;;   "g"   '(evil-goggles-mode                         :wk "Evil goggles")
      ;;   "p"   '(+org-present/start                        :wk "org-tree-slide mode"))
      )


;;
;; Keybinding fixes

;; This section is dedicated to "fixing" certain keys so that they behave
;; sensibly (and consistently with similar contexts).

;; Make SPC u SPC u [...] possible (#747)
(define-key universal-argument-map
  (kbd (concat doom-leader-key " u")) #'universal-argument-more)

(when IS-MAC
  ;; Fix MacOS shift+tab
  (define-key input-decode-map [S-iso-lefttab] [backtab])
  ;; Fix frame-switching on MacOS
  (global-set-key "M-`" #'other-frame))

(defun +default|setup-input-decode-map ()
  (define-key input-decode-map (kbd "TAB") [tab]))
(add-hook 'tty-setup-hook #'+default|setup-input-decode-map)

(after! tabulated-list
  (define-key tabulated-list-mode-map "q" #'quit-window))

(when (featurep! :feature evil +everywhere)
  ;; Evil-collection fixes
  (setq evil-collection-key-blacklist
        (list "C-j" "C-k" "gd" "gf" "K" "[" "]" "gz"
              doom-leader-key doom-localleader-key))

  (define-key! 'insert
    ;; I want C-a and C-e to be a little smarter. C-a will jump to indentation.
    ;; Pressing it again will send you to the true bol. Same goes for C-e,
    ;; except it will ignore comments and trailing whitespace before jumping to
    ;; eol.
    "C-a" #'doom/backward-to-bol-or-indent
    "C-e" #'doom/forward-to-last-non-comment-or-eol
    "C-u" #'doom/backward-kill-to-bol-and-indent
    ;; textmate-esque newline insertion
    [s-return]   #'evil-open-below
    [S-s-return] #'evil-open-above
    ;; Emacsien motions for insert mode
    "C-b" #'backward-word
    "C-f" #'forward-word
    ;; textmate-esque deletion
    [s-backspace] #'doom/backward-kill-to-bol-and-indent)

  (define-key! evil-ex-completion-map
    "C-s" (if (featurep! :completion ivy)
               #'counsel-minibuffer-history
             #'helm-minibuffer-history)
    "C-a" #'move-beginning-of-line
    "C-b" #'backward-word
    "C-f" #'forward-word)

  (define-key! view-mode-map :package 'view [escape] #'View-quit-all)

  (define-key! 'normal Man-mode-map :package 'man "q" #'kill-this-buffer))

;; Restore common editing keys (and ESC) in minibuffer
(let ((maps `(minibuffer-local-map
              minibuffer-local-ns-map
              minibuffer-local-completion-map
              minibuffer-local-must-match-map
              minibuffer-local-isearch-map
              read-expression-map
              ,@(if (featurep! :completion ivy) '(ivy-minibuffer-map)))))
  (define-key! :keymaps maps
    "C-s" (if (featurep! :completion ivy)
              #'counsel-minibuffer-history
            #'helm-minibuffer-history)
    "C-a" #'move-beginning-of-line
    "C-w" #'backward-kill-word
    "C-u" #'backward-kill-sentence
    "C-b" #'backward-word
    "C-f" #'forward-word
    "C-z" (λ! (ignore-errors (call-interactively #'undo))))
  (when (featurep! :feature evil +everywhere)
    (define-key! :keymaps maps
      [escape] #'abort-recursive-edit
      "C-r"    #'evil-paste-from-register
      "C-j"    #'next-line
      "C-k"    #'previous-line
      "C-S-j"  #'scroll-up-command
      "C-S-k"  #'scroll-down-command)))


;;
;; Universal motion repeating keys

(defvar +default-repeat-forward-key  ";")
(defvar +default-repeat-backward-key ",")

(defmacro do-repeat! (command next-func prev-func)
  "Makes ; and , the universal repeat-keys in evil-mode. These keys can be
customized by changing `+default-repeat-forward-key' and
`+default-repeat-backward-key'."
  (let ((fn-sym (intern (format "+default*repeat-%s" (doom-unquote command)))))
    `(progn
       (defun ,fn-sym (&rest _)
         (define-key! 'motion
           +default-repeat-forward-key #',next-func
           +default-repeat-backward-key #',prev-func))
       (advice-add #',command :before #',fn-sym))))

;; n/N
(do-repeat! evil-ex-search-next evil-ex-search-next evil-ex-search-previous)
(do-repeat! evil-ex-search-previous evil-ex-search-next evil-ex-search-previous)
(do-repeat! evil-ex-search-forward evil-ex-search-next evil-ex-search-previous)
(do-repeat! evil-ex-search-backward evil-ex-search-next evil-ex-search-previous)

;; f/F/t/T/s/S
(setq evil-snipe-repeat-keys nil
      evil-snipe-override-evil-repeat-keys nil) ; causes problems with remapped ;
(do-repeat! evil-snipe-f evil-snipe-repeat evil-snipe-repeat-reverse)
(do-repeat! evil-snipe-F evil-snipe-repeat evil-snipe-repeat-reverse)
(do-repeat! evil-snipe-t evil-snipe-repeat evil-snipe-repeat-reverse)
(do-repeat! evil-snipe-T evil-snipe-repeat evil-snipe-repeat-reverse)
(do-repeat! evil-snipe-s evil-snipe-repeat evil-snipe-repeat-reverse)
(do-repeat! evil-snipe-S evil-snipe-repeat evil-snipe-repeat-reverse)
(do-repeat! evil-snipe-x evil-snipe-repeat evil-snipe-repeat-reverse)
(do-repeat! evil-snipe-X evil-snipe-repeat evil-snipe-repeat-reverse)

;; */#
(do-repeat! evil-visualstar/begin-search-forward
            evil-ex-search-next evil-ex-search-previous)
(do-repeat! evil-visualstar/begin-search-backward
            evil-ex-search-previous evil-ex-search-next)
