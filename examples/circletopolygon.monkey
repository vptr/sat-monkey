Strict

Import mojo
Import sat

Class CircleToPolygon Extends App
	Field circle:Circle
	Field polygon:Polygon
	Field response:Response
	Method OnCreate:Int()
		polygon = New Polygon(160, 120, New VecStack([
			New Vec2(0,0), New Vec2(60, 0), New Vec2(100, 40), New Vec2(60, 80), New Vec2(0, 80)]))
		circle = New Circle(300, 300, 20)
		response = New Response()
		polygon.Translate(-30, -40)
		SetUpdateRate(60)
		Return 0
	End
	
	Method OnUpdate:Int()
		circle.Set(MouseX(), MouseY())
		polygon.RotatePolygon(1)
		If (SAT.TestCirclePolygon(circle, polygon, response))
			polygon.Add(response.overlapV)
		Endif
		response.Clear()
		Return 0
	End
	
	Method OnRender:Int()
		Cls()
		circle.DebugDraw()
		polygon.DebugDraw()
		Return 0
	End
End

Function Main:Int ()
	New CircleToPolygon()
	Return 0
End