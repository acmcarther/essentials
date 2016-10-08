{-# LANGUAGE TypeSynonymInstances, DeriveDataTypeable, NoMonomorphismRestriction, MultiParamTypeClasses, ImplicitParams #-}
import XMonad
import XMonad.Layout.Fullscreen ( fullscreenEventHook )
import XMonad.Layout.NoBorders ( smartBorders )
import XMonad.Layout.PerWorkspace ( onWorkspace )
import XMonad.Layout.SimplestFloat ( simplestFloat )
import XMonad.Layout.ResizableTile
    ( ResizableTall(ResizableTall),
      MirrorResize(MirrorExpand, MirrorShrink) )
import XMonad.Layout.Circle ( Circle(Circle) )
import XMonad.Layout.ThreeColumns ( ThreeCol(ThreeColMid) )
import XMonad.Layout.Grid ( Grid(Grid) )
import XMonad.Layout.WindowNavigation
    ( Direction2D(D, L, R, U), Navigate(Go, Swap), windowNavigation )
import XMonad.Layout.Reflect
    ( REFLECTY(REFLECTY), REFLECTX(REFLECTX) )
import XMonad.Layout.MultiToggle
    ( Transformer(..), Toggle(Toggle), mkToggle1 )
import XMonad.Layout.MultiToggle.Instances
    ( StdTransformers(MIRROR, NBFULL) )
import XMonad.Hooks.ManageHelpers ( isFullscreen, doFullFloat )
import XMonad.Prompt ( Direction1D(Next, Prev), defaultXPConfig )
import XMonad.Prompt.Shell ( shellPrompt )
import XMonad.Prompt.XMonad ( xmonadPrompt )
import XMonad.Util.EZConfig
    ( additionalMouseBindings, additionalKeys )
import XMonad.Actions.FloatKeys
    ( keysResizeWindow, keysMoveWindow )
import Graphics.X11.ExtraTypes.XF86
    ( xF86XK_Sleep,
      xF86XK_AudioRaiseVolume,
      xF86XK_AudioPrev,
      xF86XK_AudioPlay,
      xF86XK_AudioNext,
      xF86XK_AudioMute,
      xF86XK_AudioLowerVolume,
      xF86XK_MonBrightnessUp,
      xF86XK_MonBrightnessDown,
      )
import XMonad.Hooks.DynamicLog
    ( PP(ppCurrent, ppHidden, ppHiddenNoWindows, ppLayout, ppOrder,
         ppOutput, ppSep, ppTitle, ppUrgent, ppVisible, ppWsSep, ppExtras),
      shorten,
      trim,
      pad,
      dynamicLogWithPP,
      defaultPP )
import XMonad.Hooks.ManageDocks
    ( avoidStruts,
      ToggleStruts(ToggleStruts),
      manageDocks,
      docksEventHook )
import XMonad.Hooks.SetWMName ( setWMName )
import XMonad.Hooks.Place
    ( underMouse, placeHook, inBounds, fixed )
import XMonad.Hooks.EwmhDesktops ( ewmh )
import System.IO ( hPutStrLn )
import XMonad.Actions.GridSelect ()
import XMonad.Util.Run ( spawnPipe )
import XMonad.Actions.CycleWS
    ( WSType(EmptyWS, NonEmptyWS), moveTo )
import Control.Arrow ()
import XMonad.Util.Font ()
import XMonad.Layout.LayoutModifier ()
import XMonad.Core ()
import XMonad.StackSet ()
import qualified XMonad.Util.ExtensibleState as XS ()
import Data.List ()
import XMonad.Prompt.Directory ( directoryPrompt )
import qualified XMonad.Layout.BinarySpacePartition as BSP
import Bar
    ( ColorControl(B, F),
      Alignment(ACenter, ARight, ALeft),
      clickable2,
      clickable,
      changeColor,
      align )
import Spacing ( SPACING(SPACING), spacing )
import PerWorkspaceDirs ( getDir, currentWorkspace, changeDir )
import XMonad.Util.Loggers
import XMonad.Layout.BorderResize
import XMonad.Util.Scratchpad
import XMonad.Util.NamedScratchpad
import XMonad.Actions.Launcher
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.UrgencyHook

data FLOATED = FLOATED deriving (Read, Show, Eq, Typeable)
instance Transformer FLOATED Window where
  transform FLOATED x k = k myFloaU (const x)

myFloaU = simplestFloat
myLayout = windowNavigation
         $ smartBorders
         $ borderResize
         $ onWorkspace (myWorkspaces !! 8) (avoidStruts simplestFloat)
         $ mkToggle1 NBFULL
         $ mkToggle1 REFLECTX
         $ mkToggle1 REFLECTY
         $ mkToggle1 MIRROR
         $ mkToggle1 FLOATED
         $ avoidStruts all
           where
             all = spacing 15 BSP.emptyBSP

myWorkspaces = ["1. Alpha"
               ,"2. Beta"
               ,"3. Gamma"
               ,"4. Delta"
               ,"5. Epsilon"
               ,"6. Zeta"
               ,"7. Eta"
               ,"8. Theta"
               ,"9. Iota"
               ]

myManageHook = composeAll
        [ resource =? "dmenu"              --> doFloat
        , resource =? "pavucontrol"        --> doFloat
        , resource =? "gsimplecal"         --> placeHook ( fixed (1,20/1080) )
        , resource =? "htop"               --> placeHook ( fixed (1,35/1080) ) <+> doFloat
        , resource =? "alsamixer"          --> placeHook ( fixed (1,35/1080) ) <+> doFloat
        , resource =? "runner"             --> placeHook ( fixed (0,1) ) <+> doFloat
        , resource =? "feh"                --> doIgnore
        , resource =? "dzen2"              --> doIgnore
        , resource =? "bar-aint-recursive" --> doIgnore
        , isFullscreen                     --> doFullFloat
        , manageDocks
        ]

newManageHook = myManageHook
            <+> placeHook (inBounds (underMouse (0, 0)))
            <+> manageHook defaultConfig
            <+> scratchpadManageHookDefault

myLogHook h = dynamicLogWithPP ( defaultPP
    { ppCurrent = changeColor F (toBarC color13) . makeClickable
    , ppVisible = changeColor F (toBarC color4) . pad . makeClickable
    , ppHidden  = changeColor F (toBarC color3) . makeClickable
    , ppUrgent  = changeColor B (toBarC color3)  . makeClickable
    , ppHiddenNoWindows = makeClickable . takeWhile (/= '.')
    , ppWsSep   = " | "
    , ppSep     = "   "
    , ppLayout  = changeColor F (toBarC color10) . clickable "xdotool key super+space" . pad
    , ppTitle   = align ACenter
                . changeColor F (toBarC color10)
                . clickable2 (3::Int) "xdotool key super+shift+x"
                .  shorten 80
                . pad
    , ppOrder   = \(ws:l:t:xs) -> [trim ws, trim l, trim t ]
    , ppOutput  = hPutStrLn h
    } )
      where makeClickable ws | take 1 ws == "N" = ""
                             | otherwise = let n = take 1 ws in clickable ("xdotool key super+"++n) ws

scratchpads = [ NS "htop" "urxvt -name htop -e htop" (resource =? "htop") defaultFloating
              , NS "alsamixer" "urxvt -name alsamixer -e alsamixer" (resource =? "alsamixer") defaultFloating
              , NS "ncmpcpp" "urxvt -name ncmpcpp -e ncmpcpp" (resource =? "ncmpcpp") defaultFloating
              ]

--------------------------------------------------------------------------------------------------------------------
-- Spawn pipes and menus on boot, set default settings
--------------------------------------------------------------------------------------------------------------------
myXmonadBar :: String
myXmonadBar = "~/essentials/scripts/lemonbar/header_bar.sh | lemonbar -f \"Ubuntu Mono:medium:pixelsize=20\" -f \"FontAwesome:medium:pixelsize=15\" -B \"#000000\" | bash"
--myXmonadBar = "~/essentials/scripts/lemonbar/header_bar.sh | bar -B \"black\" | bash"

restartXmonad = "killall lemonbar; cd ~/.xmonad; ghc -threaded xmonad.hs; mv xmonad xmonad-x86_64-linux; xmonad --restart;"

spawnTerminalInDir :: String -> X ()
spawnTerminalInDir s = spawn $ "cd " ++ s ++ "; " ++ myTerminal

toBarC         :: String -> String
toBarC (x:xs)  = x : "FF" ++ xs
toBarC ""      = ""

main :: IO ()
main = do
  bar <- spawnPipe myXmonadBar
  xmonad $ withUrgencyHook NoUrgencyHook $ ewmh defaultConfig
    { terminal           = myTerminal
    , borderWidth        = 0
    , normalBorderColor  = "#2B2B2B"
    , focusedBorderColor = color5
    , modMask            = myModMask
    , layoutHook         = myLayout
    , workspaces         = myWorkspaces
    , manageHook         = newManageHook
    , handleEventHook    = fullscreenEventHook <+> docksEventHook
    , startupHook        = setWMName "LG3D"
    , logHook            = myLogHook bar  >> fadeInactiveLogHook 0.9
    }
--------------------------------------------------------------------------------------------------------------------
-- Keyboard options
--------------------------------------------------------------------------------------------------------------------
    `additionalKeys`
    [((myModMask                , xK_q     ), spawn restartXmonad)
    ,((myModMask .|. shiftMask  , xK_c     ), kill)
    ,((myModMask .|. shiftMask  , xK_b     ), spawn "firefox")
    ,((myModMask .|. shiftMask  , xK_p     ), spawn "mpc prev")
    ,((myModMask .|. shiftMask  , xK_n     ), spawn "mpc next")
    ,((myModMask .|. shiftMask  , xK_i     ), spawn "xcalib -invert -alter")
    ,((myModMask .|. shiftMask  , xK_m     ), spawn "~/.xmonad/scripts/dzen_music.sh")
    ,((myModMask .|. shiftMask  , xK_t     ), currentWorkspace >>= getDir >>= spawnTerminalInDir)
    ,((myModMask .|. shiftMask  , xK_d     ), directoryPrompt defaultXPConfig "Set working directory: " (\d -> currentWorkspace >>= changeDir d))
    ,((myModMask .|. shiftMask  , xK_h     ), sendMessage $ Swap L)
    ,((myModMask .|. shiftMask  , xK_j     ), sendMessage $ Swap D)
    ,((myModMask .|. shiftMask  , xK_k     ), sendMessage $ Swap U)
    ,((myModMask .|. shiftMask  , xK_l     ), sendMessage $ Swap R)
    ,((myModMask                , xK_h     ), sendMessage $ Go L)
    ,((myModMask                , xK_j     ), sendMessage $ Go D)
    ,((myModMask                , xK_k     ), sendMessage $ Go U)
    ,((myModMask                , xK_l     ), sendMessage $ Go R)
    ,((myModMask .|. altMask    , xK_s     ), sendMessage $ BSP.Swap)
    ,((myModMask .|. altMask    , xK_r     ), sendMessage $ BSP.Rotate)
    ,((myModMask .|. altMask    , xK_h     ), sendMessage $ BSP.ExpandTowards L)
    ,((myModMask .|. altMask    , xK_j     ), sendMessage $ BSP.ExpandTowards D)
    ,((myModMask .|. altMask    , xK_k     ), sendMessage $ BSP.ExpandTowards U)
    ,((myModMask .|. altMask    , xK_l     ), sendMessage $ BSP.ExpandTowards R)
    ,((myModMask .|. altMask .|. controlMask       , xK_h     ), sendMessage $ BSP.MoveSplit L)
    ,((myModMask .|. altMask .|. controlMask       , xK_j     ), sendMessage $ BSP.MoveSplit D)
    ,((myModMask .|. altMask .|. controlMask       , xK_k     ), sendMessage $ BSP.MoveSplit U)
    ,((myModMask .|. altMask .|. controlMask       , xK_l     ), sendMessage $ BSP.MoveSplit R)
    ,((myModMask                , xK_p     ), moveTo Prev NonEmptyWS)
    ,((myModMask                , xK_n     ), moveTo Next NonEmptyWS)
    ,((myModMask                , xK_c     ), moveTo Next EmptyWS)
    ,((myModMask                , xK_w     ), withFocused (keysMoveWindow   (0  ,-20)))
    ,((myModMask                , xK_a     ), withFocused (keysMoveWindow   (-20,  0)))
    ,((myModMask                , xK_s     ), withFocused (keysMoveWindow   (0  , 20)))
    ,((myModMask                , xK_d     ), withFocused (keysMoveWindow   (20 ,  0)))
    ,((myModMask .|. shiftMask  , xK_w     ), withFocused (keysResizeWindow (0  ,-20) (0,0)))
    ,((myModMask .|. shiftMask  , xK_a     ), withFocused (keysResizeWindow (-20,  0) (0,0)))
    ,((myModMask .|. shiftMask  , xK_s     ), withFocused (keysResizeWindow (0  , 20) (0,0)))
    ,((myModMask .|. shiftMask  , xK_d     ), withFocused (keysResizeWindow (20 ,  0) (0,0)))
    ,((myModMask                , xK_b     ), sendMessage ToggleStruts) -- toggle the statusbar gap
    ,((myModMask .|. controlMask, xK_f     ), sendMessage $ Toggle NBFULL)
    ,((myModMask .|. controlMask, xK_v     ), sendMessage $ Toggle REFLECTX)
    ,((myModMask .|. controlMask, xK_m     ), sendMessage $ Toggle MIRROR)
    ,((myModMask .|. controlMask, xK_u     ), sendMessage $ Toggle FLOATED)
    ,((myModMask .|. controlMask, xK_d     ), sendMessage $ SPACING 5)
    ,((myModMask .|. controlMask, xK_i     ), sendMessage $ SPACING (negate 5))
    ,((myModMask .|. controlMask, xK_h     ), launcherPrompt defaultXPConfig $ defaultLauncherModes launcherConfig)
    ,((myModMask                , xK_r     ), shellPrompt defaultXPConfig)
    ,((myModMask                , xK_g     ), scratchpadSpawnActionTerminal "urxvt")
    ,((myModMask                , xK_F9    ), namedScratchpadAction scratchpads "htop")
    ,((myModMask                , xK_F10   ), namedScratchpadAction scratchpads "alsamixer")
    ,((myModMask                , xK_F11   ), namedScratchpadAction scratchpads "ncmpcpp")
    ,((myModMask                , xK_F12   ), spawn "gsimplecal")
    ,((myModMask                , xK_Print ), spawn "scrot -s & mplayer /usr/share/sounds/freedesktop/stereo/screen-capture.oga")
    ,((myModMask                , xK_space ), spawn "dmenu_run -fn \"Ubuntu Mono:medium:pixelsize=25\"")
    ,((controlMask .|. altMask  , xK_t     ), spawn "urxvt")
    ,((myModMask                , xK_Return), currentWorkspace >>= getDir >>= spawnTerminalInDir)
    ,((0                        , xK_Print ), spawn "scrot & mplayer /usr/share/sounds/freedesktop/stereo/screen-capture.oga")
    ,((0                        , xF86XK_Sleep    ), spawn "pm-suspend")
    ,((0                        , xF86XK_AudioMute), spawn "amixer -q set Master toggle")
    -- WATCH OUT: These amixer values are gigantic because of my weird speaker setup
    ,((0                        , xF86XK_AudioLowerVolume), spawn "amixer -q set Master 3200-")
    ,((0                        , xF86XK_AudioRaiseVolume ), spawn "amixer -q set Master 3200+")
    ,((0                        , xF86XK_MonBrightnessDown ), spawn "xbacklight -dec 10")
    ,((0                        , xF86XK_MonBrightnessUp ), spawn "xbacklight -inc 10")
    ]
    `additionalMouseBindings`
    [((myModMask, 6), \_ -> moveTo Next NonEmptyWS)
    ,((myModMask, 7), \_ -> moveTo Prev NonEmptyWS)
    ,((myModMask, 5), \_ -> moveTo Prev NonEmptyWS)
    ,((myModMask, 4), \_ -> moveTo Next NonEmptyWS)
    ]


-- Define constants
launcherConfig = LauncherConfig { pathToHoogle = "/home/zubin/.cabal/bin/hoogle" , browser = "firefox"}
altMask = mod1Mask

myTerminal :: String
myTerminal = "urxvtc"

myBitmapsDir :: String
myBitmapsDir = "~/.xmonad/dzen2/"

myModMask :: KeyMask
myModMask = mod4Mask

myFont :: String
myFont = "-*-tamsyn-medium-r-normal-*-12-87-*-*-*-*-*-*"

background = "#181512"
foreground = "#d6c3b6"
color0     = "#332d29"
color1     = "#8c644c" -- dark brown auburn
color2     = "#746c48" -- dark greenish grey
color3     = "#bfba92" -- light grey green
color4     = "#646a6d" -- dark metal grey
color5     = "#766782" -- purple
color6     = "#4b5c5e" -- dark bluish grey
color7     = "#504339" -- very dark brown
color8     = "#817267" -- dark grey
color9     = "#9f7155" -- light brown
color10    = "#9f7155" -- still light brown
color11    = "#e0daac" -- light greenish grey
color12    = "#777eb2" -- light blue
color13    = "#897796" -- light blueish purple
color14    = "#556d70" -- dark grey blue
color15    = "#9a875f"
