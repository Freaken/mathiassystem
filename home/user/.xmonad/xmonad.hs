import XMonad
import System.Exit
import qualified XMonad.StackSet as W 
import qualified Data.Map as M
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Layout.Accordion
import XMonad.Layout.NoBorders
import XMonad.Layout
import System.IO
import Data.List (dropWhile, drop, takeWhile, find)
import Data.Maybe()

statusBarCmd= "dzen2 -bg '#1a1a1a' -fg '#ffffff' -h 12 -w 480 -sa c -e '' -ta l -fn -*-*-*-*-*-*-12-*-*-*-*-*-iso10646-1" 
dmenuCmd= "dmenu_run -nb '#1a1a1a' -nf '#ffffff' -sb '#aecf96' -sf black -p '>'"


main = do din <- spawnPipe statusBarCmd 
          xmonad $ defaultConfig
    
	               { manageHook         = myManageHook <+> manageDocks <+> manageHook defaultConfig
                   , layoutHook         = smartBorders myLayout
                   , keys               = myKeys
	               , workspaces         = map show [0 .. 9 :: Int] ++ map (: []) ['a' .. 'e']
                   , logHook            = dynamicLogWithPP $ myPP din
                   , modMask            = mod4Mask     -- Rebind Mod to the Windows key
                   , normalBorderColor  = "#555555"
                   , focusedBorderColor = "#bbbbbb"
	               , borderWidth 	    = 1
                   , startupHook        = (setWMName "LG3D" >> spawn "killall xbindkeys; xbindkeys")
                   }

-- ManageHooks
myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Pidgin" --> doShift "e"
    , className =? "Skype" --> doShift "e"
    , className =? "Transmission" --> doShift "d"
    , className =? "Deluge" --> doShift "d"
    , className =? "Quodlibet" --> doShift "c"
--    , className =? "Wine" --> doFloat
    , isFullscreen --> doFullFloat]


-- Layouts
myLayout = avoidStruts (tiled ||| Mirror tiled ||| Full)
  where
    tiled = Tall 1 (3/100) (1/2)

-- Pretty print for dzen
myPP h = defaultPP
                 { ppCurrent = dzenColor "black" "#aecf96"
				 , ppHidden  = dzenColor "" ""
				 , ppSep     = " ^r(3x3) "
				 -- Replace layout name with an icon:
			 	 , ppTitle   = dzenColor "aecf96" ""
				 , ppOutput  = hPutStrLn h
				 }

-- Keys
myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modMask, XMonad.workspaces = workspaces}) = M.fromList $
    -- killing programs
    [ ((modMask .|. shiftMask, xK_c ), kill)

    -- layouts
    , ((modMask, xK_space ), sendMessage NextLayout)
    , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- focus
    , ((modMask, xK_Tab ), windows W.focusDown)
    , ((modMask, xK_j ), windows W.focusDown)
    , ((modMask, xK_k ), windows W.focusUp)
    , ((modMask, xK_m ), windows W.focusMaster)

    -- floating layer support
    , ((modMask, xK_t ), withFocused $ windows . W.sink)
    , ((modMask, xK_b ), sendMessage ToggleStruts) -- Removes top bar

    -- swapping
    , ((modMask .|. shiftMask, xK_j ), windows W.swapDown )
    , ((modMask .|. shiftMask, xK_k ), windows W.swapUp )

    -- increase or decrease number of windows in the master area
    , ((modMask , xK_comma ), sendMessage (IncMasterN 1))
    , ((modMask , xK_period), sendMessage (IncMasterN (-1)))

    -- resizing
    , ((modMask, xK_h ), sendMessage Shrink)
    , ((modMask, xK_l ), sendMessage Expand)
    --, ((modMask .|. shiftMask, xK_h ), sendMessage MirrorShrink)
    --, ((modMask .|. shiftMask, xK_l ), sendMessage MirrorExpand)

    -- quit, or restart
    , ((modMask .|. shiftMask, xK_q ), io (exitWith ExitSuccess))
    , ((modMask , xK_q ), restart "xmonad" True)
    ]
    ++
    -- mod-[1..9] %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip workspaces (xK_onehalf : [xK_1 .. xK_9] ++ [xK_0, xK_plus, 65105, xK_BackSpace, xK_Home]) ++ -- 65105 is the key after the plus key on my keyboard
                    zip ["0", "b", "c"] [xK_grave, xK_minus, xK_equal] -- Colemak layout
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    -- mod-[a,s] + mod-[left,right]:
    --      move to left/right workspace
    -- mod-shift-[a,s] + mod-shift-[left,right]:
    --      move to left/right workspace that contains anything
    [((m .|. modMask, k), windows $ f workspaces i)
        | (i, k) <- [(-1, xK_a), (1, xK_s), (-1, xK_Left), (1, xK_Right)]
        , (m, f) <- [(0, getTag False), (shiftMask, getTag True)]
    ]
    ++
    -- mod-{w,e,r} %! Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r} %! Move client to screen 1, 2, or 3
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

getTag :: Bool -> [String] -> Int -> WindowSet -> WindowSet
getTag allowEmpty all_tags diff s = if diff == 0 then s else
    W.greedyView new_tag s
    where cur_tag = W.currentTag s
          possible_next = if diff > 0
                          then drop 1  $ dropWhile (/=cur_tag) all_tags
                          else reverse $ takeWhile (/=cur_tag) all_tags
          getStack tag = find ((==tag) . W.tag) (W.workspaces s) >>= W.stack
          filter_empty = maybe False (not . null . W.integrate) . getStack
          filtered = if allowEmpty
                     then possible_next
                     else filter filter_empty possible_next
          new_tag = if null filtered
                    then cur_tag
                    else filtered !! ((min (abs diff) (length filtered))-1)
