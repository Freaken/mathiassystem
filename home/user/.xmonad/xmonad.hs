import XMonad
import System.Exit
import qualified XMonad.StackSet as W 
import qualified Data.Map as M
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Hooks.ManageHelpers
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Layout.NoBorders
import XMonad.Layout.Accordion
import XMonad.Layout
import XMonad.Actions.CycleWS
import System.IO

statusBarCmd= "dzen2 -bg '#1a1a1a' -fg '#ffffff' -h 12 -w 480 -sa c -e '' -ta l -fn -*-*-*-*-*-*-12-*-*-*-*-*-iso10646-1" 
dmenuCmd= "dmenu_run -nb '#1a1a1a' -nf '#ffffff' -sb '#aecf96' -sf black -p '>'"


main = do din <- spawnPipe statusBarCmd 
          xmonad $ defaultConfig
    
	               { manageHook         = myManageHook <+> manageDocks <+> manageHook defaultConfig
                   --, layoutHook         = smartBorders(myLayout)
                   , layoutHook         = myLayout
                   , keys               = myKeys
	               , workspaces         = map show [0 .. 9 :: Int] ++ ["a", "b", "c", "d"]
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
    [ isFullscreen --> doFullFloat
    , className =? "Pidgin" --> doShift "d"
    , className =? "Skype" --> doShift "d"
    --, className =? "Transmission" --> doShift "c"
    , className =? "Keepassx" --> doShift "b"
	, title     =? "VLC media player" --> doFloat
	, title     =? "VLC (XVideo output)" --> doFloat]


-- DropNumbers removes the number if a workspace is named, i:name -> name
dropNumbers wsId =  if (':' `elem` wsId) 
                    then drop 2 wsId
			        else wsId

-- Layouts
myLayout = avoidStruts (tiled ||| Mirror tiled ||| Full)
  where
    tiled = Tall 1 (3/100) (1/2)
    nmaster = 1
    ratio   = 1/2
    delta   = 3/100

-- Pretty print for dzen
myPP h = defaultPP
                 { ppCurrent = dzenColor "black" "#aecf96" . dropNumbers
				 , ppHidden  = dzenColor "" "" . dropNumbers
				 , ppSep     = " ^r(3x3) "
				 -- Replace layout name with an icon:
			 	 , ppTitle   = dzenColor "aecf96" ""
				 , ppOutput  = hPutStrLn h
				 }

-- Keys
myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
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
	, ((modMask, xK_Return), windows W.swapMaster)

    -- floating layer support
    , ((modMask, xK_t ), withFocused $ windows . W.sink)

    -- swapping
    , ((modMask .|. shiftMask, xK_j ), windows W.swapDown )
    , ((modMask .|. shiftMask, xK_k ), windows W.swapUp )

    -- increase or decrease number of windows in the master area
    , ((modMask , xK_comma ), sendMessage (IncMasterN 1))
    , ((modMask , xK_period), sendMessage (IncMasterN (-1)))

	-- switch between current and previous workspace
	, ((modMask .|. shiftMask , xK_w ), toggleWS )

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
        | (i, k) <- zip (XMonad.workspaces conf) ([xK_onehalf] ++ [xK_1 .. xK_9] ++ [xK_0, xK_plus, 65105, xK_BackSpace]) -- 65105 is the key after the plus key on my keyboard
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    -- mod-{w,e,r} %! Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r} %! Move client to screen 1, 2, or 3
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]



