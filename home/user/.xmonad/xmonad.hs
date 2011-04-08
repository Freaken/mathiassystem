import XMonad
import XMonad.Actions.NoBorders
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook
import XMonad.Layout
import XMonad.Layout.Grid
import XMonad.Layout.IM
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Prompt
import XMonad.Prompt.Man
import XMonad.Prompt.Shell
import XMonad.Util.Loggers
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.Scratchpad
import XMonad.Util.WorkspaceCompare
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import System.Exit
import System.IO
import System.Posix.Unistd(sleep)
import Data.List(dropWhile, drop, find, takeWhile, union)
import Data.Maybe()
import Data.Ratio ((%))

main = do din <- spawnPipe "xmobar"
          sleep 2 -- Wait for xmobar to start
          xmonad $ withUrgencyHook NoUrgencyHook
                 $ defaultConfig
                   { manageHook         = scratchpadManageHook (W.RationalRect 0 0 1 0.375) <+>
                                          manageDocks <+>
                                          myManageHook <+>
                                          manageHook defaultConfig
                   , layoutHook         = smartBorders myLayout
                   , keys               = myKeys
                   , workspaces         = myWorkspaces 
                   , logHook            = dynamicLogWithPP $ myPP din
                   , modMask            = mod4Mask
                   , normalBorderColor  = "#555555"
                   , focusedBorderColor = "#bbbbbb"
                   , borderWidth        = 1
                   , startupHook        = do setWMName "LG3D"
                                             spawn "killall xbindkeys; xbindkeys"
                   }

myWorkspaces = map (: []) $ ['0'..'9'] ++ ['a'..'e']

myWorkspaceKeys = zip myWorkspaces normal_keys ++ colemak
  where colemak     = zip ["0", "b", "c"] [xK_grave, xK_minus, xK_equal]
        normal_keys = [xK_onehalf] ++
                      [xK_1..xK_9] ++
                      [xK_0, xK_plus, 65105, xK_BackSpace, xK_Home]
          
myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Transmission"    --> doShift "d"
    , className =? "Transgui"        --> doShift "d"
    , className =? "Xchat"           --> doShift "c"
    , className =? "Pidgin"          --> doShift "e"
    , className =? "Skype"           --> doShift "e"
    , appName   =? "mplayer_seek.py" --> doCenterFloat 
    , isFullscreen                   --> doFullFloat]

myPrompt = defaultXPConfig
       { font = "-*-*-*-*-*-*-12-*-*-*-*-*-iso8859-*"
       , bgColor = "#1a1a1a"
       , fgColor = "#ffffff"
       , promptBorderWidth = 0
       , position = Top
       }

myLayout = avoidStruts $ onWorkspace "e" (withIM (1%5) (Role "buddy_list") Grid) $
                         Full ||| GridRatio (4/3) ||| Grid
--myLayout = avoidStruts (withIM (1%7) (Role "buddy_list") (tiled ||| Mirror tiled ||| Full))
  where
    tiled = Tall 1 (3/100) (1/2)

-- Pretty print for xmobar
myPP h = defaultPP
                 { ppCurrent = xmobarColor "black" "#aecf96"
                 , ppSep     = " | "
                 , ppUrgent  = xmobarColor "black" "#ff8c00"
                 , ppOrder   = \(w : l : t : _) -> [l, w, t]
                 , ppLayout  = (: []) . head
                 , ppSort    = getSortByIndex >>= \f -> return $ f . filter (\w-> W.tag w /= "NSP") -- Removes the NSP workspace
                 , ppOutput  = hPutStrLn h
                 }

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {modMask = modMask}) = M.fromList $
    -- killing programs
    [ ((modMask .|. shiftMask, xK_c), kill)

    -- layouts
    , ((modMask, xK_space), sendMessage NextLayout)
    , ((modMask .|. shiftMask, xK_space), setLayout $ layoutHook conf)

    -- focus
    , ((modMask, xK_Tab), windows W.focusDown)
    , ((modMask, xK_j), windows W.focusDown)
    , ((modMask, xK_k), windows W.focusUp)
    , ((modMask, xK_m), windows W.focusMaster)

    -- floating layer support
    , ((modMask, xK_t ), withFocused $ windows . W.sink)
    , ((modMask, xK_b ), sendMessage ToggleStruts) -- Removes top bar

    -- swapping
    , ((modMask .|. shiftMask, xK_j ), windows W.swapDown )
    , ((modMask .|. shiftMask, xK_k ), windows W.swapUp )

    -- increase or decrease number of windows in the master area
    , ((modMask, xK_comma), sendMessage (IncMasterN 1))
    , ((modMask, xK_period), sendMessage (IncMasterN (-1)))

    -- resizing
    , ((modMask, xK_h ), sendMessage Shrink)
    , ((modMask, xK_l ), sendMessage Expand)

    -- quit, or restart
    , ((modMask .|. shiftMask, xK_q ), io (exitWith ExitSuccess))
    , ((modMask, xK_q ), restart "xmonad" True)

    -- Shell?!?
    , ((modMask, xK_p), shellPrompt myPrompt)
    , ((modMask, xK_m), manPrompt myPrompt)
    , ((0, xK_Hyper_L), scratchpadSpawnActionCustom "gnome-terminal --window-with-profile=Grey --disable-factory --name scratchpad")
    ]
    ++
    -- mod-[1..9] %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- myWorkspaceKeys
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    -- mod-[a,s] + mod-[left,right]:
    --      move to left/right workspace
    -- mod-shift-[a,s] + mod-shift-[left,right]:
    --      move to left/right workspace that contains anything
    [((m .|. modMask, k), windows $ f (workspaces conf) i)
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
getTag allowEmpty all_tags diff s = if diff == 0
                                    then s
                                    else W.greedyView new_tag s
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
