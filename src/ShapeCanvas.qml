import QtQuick 2.1
import "graphicProcess.js" as CalcGraphic

Canvas {
	id: canvas
	width: parent.width
	height: parent.height

	property bool recording: false
	property string shapeName: "rect"
	property var shapes: []
	property var currenRecordingShape
	property var linewidth: 3
	property color paintColor: "red"
	property alias canvasArea: canvasArea
	property url imageUrl: "/tmp/deepin-screenshot.png"
	property string blurImage:"/tmp/deepin-screenshot-blur.png"
	property string mosaicImage: "/tmp/deepin-screenshot-mosaic.png"
	property bool isBlur: false
	property bool bluring:false
	property bool processBlur: false
	property var blurImageData

	property bool isMosaic: false
	property bool mosaicing: false
	property bool processMosaic: false
	property var mosaicImageData

	function reLoadImage(image) { unloadImage(image); loadImage(image) }

	onIsBlurChanged: { if (isBlur) { reLoadImage(blurImage) } }
	onIsMosaicChanged: { if (isMosaic) { reLoadImage(mosaicImage) } }

	onImageLoaded: {
		if (isBlur) {
			bluring = true
		}
		if (isMosaic) {
			mosaicing = true
		}
		requestPaint()
	}
	onPaint: {

		var ctx = canvas.getContext("2d")
		ctx.clearRect(x, y, width, height)
		if ( processBlur || processMosaic ) {
			ctx.beginPath()
			ctx.rect(x, y, width, height)
			ctx.clip()
		}
		if(bluring || mosaicing) {
			if (bluring) {
				var imageData = ctx.createImageData(blurImage)
				imageData = CalcGraphic.gaussianBlur(imageData, 1)
				blurImageData = imageData
				bluring = false
				} else {
					var imageData = ctx.createImageData(mosaicImage)
					imageData = CalcGraphic.mosaic(imageData, 5)
					mosaicImageData = imageData
					mosaicing = false
				}
				} else {
					ctx.strokeStyle = "red"
					for (var i = 0; i < shapes.length; i++) {
						shapes[i].draw(ctx)
					}
				}

			}

			function clickOnPoint(p) {
				for (var i = 0; i < shapes.length; i++) {
					if (shapes[i].selected || shapes[i].reSized) {
						shapes[i].rotateOnPoint(p)
					}
				}

				for (var i = 0; i < shapes.length; i++) {

					if (shapes[i].clickOnPoint(p)){
						var selectedShape = i
					}
				}

				if (selectedShape != null ) {
					for (var i = 0; i < shapes.length && i != selectedShape; i++) {
						shapes[i].selected = false
						shapes[i].reSized = false
					}
					return true
					} else {
						for (var i = 0; i < shapes.length; i++) {
							shapes[i].selected = false
							shapes[i].reSized = false
							shapes[i].rotated = false
						}
						return false
					}
				}
				function resizeOnPoint(p) {
					for (var i = 0; i < shapes.length; i++) {
						if (shapes[i].resizeOnPoint(p)) {
							return true
						}
					}
					return false
				}
				function rotateOnPoint(p) {
					for (var i = 0; i < shapes.length; i++) {
						if (shapes[i].rotateOnPoint(p)) {
							return true
						}
					}
					return false
				}
				function hoverOnShape(p) {
					for (var i = 0; i < shapes.length; i++) {
						if (shapes[i].hoverOnShape(p)) {
							return true
						}
					}
					return false
				}
				function mouse_style(shape,paint) {
					switch (shape) {
						case "rect": { return windowView.set_cursor_shape("../image/mouse_style/shape/rect_mouse.png", 5, 5)}
						case "ellipse": { return windowView.set_cursor_shape("../image/mouse_style/shape/ellipse_mouse.png", 5, 5)}
						case "arrow": { return windowView.set_cursor_shape("../image/mouse_style/shape/arrow_mouse.png", 5, 5)}
						case "line": {
							if(paint == "#ffd903")   {return windowView.set_colorpen_cursor_shape("../image/mouse_style/color_pen/yellow.png")}
							if(paint == "#ff5e1a")   {return windowView.set_colorpen_cursor_shape("../image/mouse_style/color_pen/orange.png")}
							if(paint == "#ff3305")   {return windowView.set_colorpen_cursor_shape("../image/mouse_style/color_pen/dark_orange.png")}
							if(paint ==  "#ff1c49")  {return windowView.set_colorpen_cursor_shape("../image/mouse_style/color_pen/pink_red.png")}
							if(paint == "#fb00ff")   {return windowView.set_colorpen_cursor_shape("../image/mouse_style/color_pen/light_purple.png")}
							if(paint == "#7700ed")   {return windowView.set_colorpen_cursor_shape("../image/mouse_style/color_pen/purple.png")}
							if(paint == "#3d08ff")   {return windowView.set_colorpen_cursor_shape("../image/mouse_style/color_pen/dark_blue.png")}
							if(paint == "#3468ff")   {return windowView.set_colorpen_cursor_shape("../image/mouse_style/color_pen/blue.png")}
							if(paint == "#00aaff")   {return windowView.set_colorpen_cursor_shape("../image/mouse_style/color_pen/light_blue.png")}
							if(paint == "#08ff77")   {return windowView.set_colorpen_cursor_shape("../image/mouse_style/color_pen/light_green.png")}
							if(paint == "#03a60e")   {return windowView.set_colorpen_cursor_shape("../image/mouse_style/color_pen/grass_green.png")}
							if(paint == "#3c7d00")   {return windowView.set_colorpen_cursor_shape("../image/mouse_style/color_pen/dark_green.png")}
							if(paint == "#ffffff")   {return windowView.set_colorpen_cursor_shape("../image/mouse_style/color_pen/white.png")}
							if(paint == "#666666")   {return windowView.set_colorpen_cursor_shape("../image/mouse_style/color_pen/grey.png")}
							if(paint == "#2b2b2b")   {return windowView.set_colorpen_cursor_shape("../image/mouse_style/color_pen/dark_grey.png")}
							if(paint == "#000000")   {return windowView.set_colorpen_cursor_shape("../image/mouse_style/color_pen/black.png")}
						}
					}
				}
				Component {
					id: rect_component
					RectangleCanvas {}
				}
				Component {
					id: ellipse_component
					EllipseCanvas {}
				}
				Component {
					id: arrow_component
					ArrowCanvas {}
				}
				Component {
					id: line_component
					LineCanvas {}
				}
				MouseArea {
					id: canvasArea
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: canvas.mouse_style(canvas.shapeName, canvas.paintColor)
					onPressed: {

						if (!canvas.clickOnPoint(Qt.point(mouse.x, mouse.y))) {
							canvas.recording = true
							if (canvas.shapeName == "rect") {
								canvas.currenRecordingShape = rect_component.createObject(canvas, {})
							}
							if (canvas.shapeName == "ellipse") {
								canvas.currenRecordingShape = ellipse_component.createObject(canvas, {})
							}
							if (canvas.shapeName == "arrow") {
								canvas.currenRecordingShape = arrow_component.createObject(canvas, {})
							}
							if (canvas.shapeName == "line") {
								canvas.currenRecordingShape = line_component.createObject(canvas, {})
							}
							canvas.currenRecordingShape.linewidth = canvas.linewidth
							canvas.currenRecordingShape.drawColor = canvas.paintColor
							canvas.currenRecordingShape.points.push(Qt.point(mouse.x, mouse.y))
							canvas.shapes.push(canvas.currenRecordingShape)
						}

						canvas.requestPaint()
					}
					onReleased: {
						if (canvas.recording) {
							canvas.currenRecordingShape.points.push(Qt.point(mouse.x, mouse.y))
							canvas.currenRecordingShape.firstDraw = true
							canvas.recording = false
							canvas.requestPaint()

						}


					}

					onPositionChanged: {
						if (canvas.recording && pressed) {
							canvas.currenRecordingShape.points.push(Qt.point(mouse.x, mouse.y))
							canvas.requestPaint()
							} else if(!canvas.recording && pressed) {
								var selectedShape = null,reSizedShape = null,rotatedShape = null
								for (var i = 0; i < canvas.shapes.length; i++) {
									if (canvas.shapes[i].reSized||drag.active)  reSizedShape = canvas.shapes[i]
									if (canvas.shapes[i].rotated||drag.active) rotatedShape = canvas.shapes[i]
									if (canvas.shapes[i].selected||drag.active)  selectedShape = canvas.shapes[i]
								}
								if (selectedShape != null && pressed) {
									selectedShape.handleDrag(Qt.point(mouse.x, mouse.y))

									canvas.requestPaint()
								}
								if (reSizedShape != null && pressed) {
									reSizedShape.handleResize(Qt.point(mouse.x, mouse.y), reSizedShape.clickedKey)

									canvas.requestPaint()
								}
								if (rotatedShape != null && pressed) {
									canvasArea.cursorShape =  windowView.set_cursor_shape("../image/mouse_style/shape/rotate_mouse.png", -1, -1)
									rotatedShape.handleRotate(Qt.point(mouse.x, mouse.y))
									canvas.requestPaint()
								}
								} else {
									for (var i = 0; i < canvas.shapes.length;i++ ) {

										if (canvas.shapes[i].reSized || canvas.shapes[i].selected || canvas.shapes[i].rotated) {
											if (canvas.shapes[i].hoverOnRotatePoint(Qt.point(mouse.x, mouse.y))) {
												canvasArea.cursorShape =  windowView.set_cursor_shape("../image/mouse_style/shape/rotate_mouse.png", -1, -1)
											}
											if (!canvas.shapes[i].hoverOnRotatePoint(Qt.point(mouse.x, mouse.y))) {
												canvasArea.cursorShape = canvas.mouse_style(canvas.shapeName, canvas.paintColor)
											}
										}
									}
									canvas.hoverOnShape(Qt.point(mouse.x, mouse.y))
									canvas.requestPaint()
								}
							}
						}

					}
