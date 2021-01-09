// Copyright (c) 2020 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a GPL license
// that can be found in the LICENSE file.
module ui

import gx
import gg
type Example = []gx.Color | gx.Color

pub struct Rectangle {
pub mut:
	color        Example
	text         string
mut:
	parent       Layout
	x            int
	y            int
	height       int
	width        int
	radius       int
	border       bool
	border_color gx.Color
	ui           &UI
}
pub struct RectangleConfig {
	// textute    {
	// 			path:
	// 			degree:
	// 			scale{
	// 				x:
	// 				y:
	// 			}

	// 		}
	// gradient_manager	{
	// 			 vertex_colors
	// 			 degree
	// 			 stops
	// 			 resolution				 	
	// 			}
	text         string
	height       int
	width        int
	color        Example
	radius       int
	border       bool
	border_color gx.Color = gx.Color{
	r: 180
	g: 180
	b: 190
}
	x            int
	y            int
}

fn (mut r Rectangle) init(parent Layout) {
	ui := parent.get_ui()
	r.ui = ui
}

pub fn rectangle(c RectangleConfig) &Rectangle {
	rect := &Rectangle{
		text: c.text
		height: c.height
		width: c.width
		radius: c.radius
		color: c.color
		border: c.border
		border_color: c.border_color
		ui: 0
		x: c.x
		y: c.y
	}
	return rect
}

fn (mut r Rectangle) set_pos(x int, y int) {
	r.x = x
	r.y = y
}

fn (mut r Rectangle) size() (int, int) {
	return r.width, r.height
}

fn (mut r Rectangle) propose_size(w int, h int) (int, int) {
	return r.width, r.height
}

fn (mut r Rectangle) draw() {
	color_type:=r.color
	mut color1:=gx.red
	mut color2:=[]gx.Color
	if color_type is gx.Color{
		color1=color_type
	}
	if color_type is []gx.Color{
		color2=r.color as []gx.Color
		color1=color2[0]
	}
	if r.radius > 0 {
		// r.ui.gg.draw_rounded_rect(r.x, r.y, r.width, r.height, r.radius, r.color)		
		r.ui.gg.draw_rounded_rect(r.x, r.y, r.width, r.height, r.radius, color1)
		if r.border {
			r.ui.gg.draw_empty_rounded_rect(r.x, r.y, r.width, r.height, r.radius, r.border_color)
		}
	} else {
		// r.ui.gg.draw_rect(r.x, r.y, r.width, r.height, r.color)
		r.ui.gg.new_draw_rect({
			height:any_float(r.height),
			width:any_float(r.width), 
			pos_x:any_float(r.x), 
			pos_y:any_float(r.y),
			backgroud_color:color2
			})

		if r.border {
			r.ui.gg.draw_empty_rect(r.x, r.y, r.width, r.height, r.border_color)
		}
	}
	text_cfg := gx.TextCfg{
		color: gx.red
		align: gx.align_left
		max_width: r.x + r.width
	}
	// Display rectangle text
	if r.text != '' {
		text_width, text_height := r.ui.gg.text_size(r.text)
		mut dx := (r.width - text_width) / 2
		mut dy := (r.height - text_height) / 2
		if dx < 0 {
			dx = 0
		}
		if dy < 0 {
			dy = 0
		}
		r.ui.gg.draw_text(r.x + dx, r.y + dy, r.text, text_cfg)
	}
}

fn (r &Rectangle) focus() {
}

fn (r &Rectangle) is_focused() bool {
	return false
}

fn (r &Rectangle) unfocus() {
}

fn (r &Rectangle) point_inside(x f64, y f64) bool {
	return false
}
