// Copyright (c) 2020 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a GPL license
// that can be found in the LICENSE file.
module ui
import gx
import gg
import os
import eventbus

const (
	button_bg_color           = gx.rgb(28, 28, 28)
	button_border_color       = gx.rgb(200, 200, 200)
	btn_text_cfg              = gx.TextCfg{ // color: gx.white, {
		color: gx.rgb(38, 38, 38)
		align: gx.align_left
	}
	button_horizontal_padding = 26
	button_vertical_padding   = 8
)

enum ButtonState {
	normal
	pressed
}

type ButtonClickFn = fn (voidptr, voidptr) // userptr, btn
type ButtonHoverFn = fn (voidptr, voidptr) // userptr, btn

pub struct ButtonConfig {
	cursor	  int//C.LPCSTR
	text      string
	icon_path string
	onclick   ButtonClickFn	
	onhover   ButtonHoverFn
	height    int = 20
	width     int
	color	  gx.Color=gx.white
}

[ref_only]
pub struct Button {
mut:
	text_width  int
	text_height int
	is_toggle   bool
pub mut:
	state       ButtonState
	height      int
	width       int
	x           int
	y           int
	parent      Layout
	is_focused  bool
	is_hover	bool
	ui          &UI
	onclick     ButtonClickFn	
	onhover     ButtonHoverFn
	text        string
	icon_path   string
	image       gg.Image
	use_icon    bool
	color 		gx.Color
	cursor 	 	int
}

fn (mut b Button) init(parent Layout) {
	b.parent = parent
	ui := parent.get_ui()
	b.ui = ui
	if b.use_icon {
		b.image = b.ui.gg.create_image(b.icon_path)
	}
	mut subscriber := parent.get_subscriber()
	subscriber.subscribe_method(events.on_click, btn_click, b)
	subscriber.subscribe_method(events.on_mouse_move, btn_hover, b)
}

pub fn button(c ButtonConfig) &Button {
	mut b := &Button{
		width: c.width
		height: c.height
		text: c.text
		icon_path: c.icon_path
		use_icon: c.icon_path != ''
		onclick: c.onclick
		onhover: c.onhover
		color:c.color
		ui: 0
		cursor: c.cursor
	}
	if b.use_icon && !os.exists(c.icon_path) {
		println('Invalid icon path "$c.icon_path". The alternate text will be used.')
		b.use_icon = false
	}
	return b
}

fn btn_click(mut b Button, e &MouseEvent,mut window &Window) {
	// println('btn_click for window=$window.title')
	if b.point_inside(e.x, e.y) {
		if e.action == .down {
			b.state = .pressed
		} else if e.action == 0 {
			b.state = .normal
			if b.onclick != voidptr(0) {
				b.onclick(window.state, b)
				window.cursor=b.cursor//C.IDC_HAND
				
			}
		}
	}
}

fn btn_hover(mut b Button, e &MouseMoveEvent,mut window &Window) {
	 b.is_toggle=false
		
	if b.point_inside(e.x, e.y) {
		if b.onhover != voidptr(0) {
			b.onhover(window.state, b)
		}
		gg.set_cursor(b.cursor)//(C.IDC_HAND)
		window.cursor=b.cursor//C.IDC_HAND
		b.is_toggle=false
	}else if window.cursor!=C.IDC_ARROW && !b.is_toggle{
		gg.set_cursor(C.IDC_ARROW)
		window.cursor=C.IDC_ARROW
		b.is_toggle=true
	}
}

fn (mut b Button) set_pos(x int, y int) {
	b.x = x
	b.y = y
}

fn (mut b Button) size() (int, int) {
	return b.width, b.height
}

fn (mut b Button) propose_size(w int, h int) (int, int) {
	// b.width = w
	// b.height = h
	// b.width = b.ui.ft.text_width(b.text) + button_horizontal_padding
	// b.height = 20 // vertical padding
	return b.width, b.height
}

fn (mut b Button) draw() {
	if b.use_icon {
		b.width = b.image.width
		b.height = b.image.height
	} else if b.text_width == 0 || b.text_height == 0 {
		b.text_width, b.text_height = b.ui.gg.text_size(b.text)
		b.width = b.text_width + button_horizontal_padding
		b.height = b.text_height + button_vertical_padding
	}
	w2 := b.text_width / 2
	h2 := b.text_height / 2
	bcenter_x := b.x + b.width / 2
	bcenter_y := b.y + b.height / 2
	bg_color := if b.state == .normal { b.color } else { progress_bar_background_color } // gx.gray }
	b.ui.gg.draw_rect(b.x, b.y, b.width, b.height, bg_color) // gx.white)
	b.ui.gg.draw_empty_rect(b.x, b.y, b.width, b.height, button_border_color)
	mut y := bcenter_y - h2 - 1
	// if b.ui.gg.scale == 2 {
	$if macos { // TODO
		y -= 2
	}
	if b.use_icon {
		b.ui.gg.draw_image(b.x, b.y, b.width, b.height, b.image)
	} else {
		b.ui.gg.draw_text(bcenter_x - w2, y, b.text, btn_text_cfg)
	}
	// b.ui.gg.draw_empty_rect(bcenter_x-w2, bcenter_y-h2, text_width, text_height, button_border_color)
}

// fn (b &Button) key_down(e KeyEvent) {}
fn (b &Button) point_inside(x f64, y f64) bool {
	return x >= b.x && x <= b.x + b.width && y >= b.y && y <= b.y + b.height
}

// fn (mut b Button) mouse_move(e MouseEvent) {}
fn (mut b Button) focus() {
	b.is_focused = true
}

fn (mut b Button) unfocus() {
	b.is_focused = false
	b.state = .normal
}

fn (b &Button) is_focused() bool {
	return b.is_focused
}

// IDC_APPSTARTING
// MAKEINTRESOURCE(32650)
// Standard arrow and small hourglass
// IDC_ARROW
// MAKEINTRESOURCE(32512)
// Standard arrow
// IDC_CROSS
// MAKEINTRESOURCE(32515)
// Crosshair
// IDC_HAND
// MAKEINTRESOURCE(32649)
// Hand
// IDC_HELP
// MAKEINTRESOURCE(32651)
// Arrow and question mark
// IDC_IBEAM
// MAKEINTRESOURCE(32513)
// I-beam
// IDC_ICON
// MAKEINTRESOURCE(32641)
// Obsolete for applications marked version 4.0 or later.
// IDC_NO
// MAKEINTRESOURCE(32648)
// Slashed circle
// IDC_SIZE
// MAKEINTRESOURCE(32640)
// Obsolete for applications marked version 4.0 or later. Use IDC_SIZEALL.
// IDC_SIZEALL
// MAKEINTRESOURCE(32646)
// Four-pointed arrow pointing north, south, east, and west
// IDC_SIZENESW
// MAKEINTRESOURCE(32643)
// Double-pointed arrow pointing northeast and southwest
// IDC_SIZENS
// MAKEINTRESOURCE(32645)
// Double-pointed arrow pointing north and south
// IDC_SIZENWSE
// MAKEINTRESOURCE(32642)
// Double-pointed arrow pointing northwest and southeast
// IDC_SIZEWE
// MAKEINTRESOURCE(32644)
// Double-pointed arrow pointing west and east
// IDC_UPARROW
// MAKEINTRESOURCE(32516)
// Vertical arrow
// IDC_WAIT
// MAKEINTRESOURCE(32514)