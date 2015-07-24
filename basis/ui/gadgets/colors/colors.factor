! Copyright (C) 2015 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: colors colors.constants ;
IN: ui.gadgets.colors

CONSTANT: toolbar-background COLOR: grey95

CONSTANT: menu-background COLOR: grey95
CONSTANT: menu-border-color COLOR: grey75

CONSTANT: status-bar-background COLOR: FactorDarkSlateBlue
CONSTANT: status-bar-foreground COLOR: white

CONSTANT: line-color COLOR: grey75

CONSTANT: source-files-color COLOR: NavajoWhite
CONSTANT: errors-color COLOR: chocolate1
CONSTANT: details-color COLOR: SlateGray2

CONSTANT: debugger-color COLOR: chocolate1

CONSTANT: data-stack-color COLOR: DodgerBlue
CONSTANT: retain-stack-color COLOR: HotPink
CONSTANT: call-stack-color COLOR: GreenYellow

CONSTANT: title-bar-gradient { COLOR: white COLOR: grey90 }

CONSTANT: popup-color COLOR: yellow ! to be changed

CONSTANT: object-color COLOR: aquamarine2
CONSTANT: contents-color COLOR: orchid2

CONSTANT: help-header-background
T{ rgba { red 0.9568 } { green 0.9450 } { blue 0.8509 } { alpha 1.0 } } inline

CONSTANT: thread-status-background
T{ rgba { red 0.9295 } { green 0.9569 } { blue 0.8510 } { alpha 1.0 } } inline

CONSTANT: error-summary-background
T{ rgba { red 0.9568 } { green 0.8509 } { blue 0.8509 } { alpha 1.0 } } inline

CONSTANT: content-background COLOR: white

: white-interior ( track -- track )
    content-background <solid> >>interior ;
