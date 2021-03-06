#REM
	Version 0.4 - Copyright 2014 -  Jim Riecken <jimr@jimr.ca>
	Released under the MIT License - https://github.com/jriecken/sat-js
	A simple library for determining intersections of circles and
	polygons using the Separating Axis Theorem.
	@preserve SAT.js - Version 0.4 - Copyright 2014 - Jim Riecken <jimr@jimr.ca> - 
	released under the MIT License. https://github.com/jriecken/sat-js
	
	Ported to Monkey by Felipe Alfonso <contact@shin.cl> -
	https://github.com/ilovepixel/sat-monkey/
#END

Strict

Import mojo
Import sat.vec2
Import sat.base
Import sat.vecstack
Import sat.rectangle

Class Polygon Extends Vec2
	
	Private
	
	Field xMin:Float
	Field yMin:Float
	Field xMax:Float
	Field yMax:Float
	Field bounds:Rectangle
	
	Public
	
	Field points:VecStack
	Field angle:Float
	Field offset:Vec2
	Field edges:VecStack
	Field normals:VecStack
	Field calcPoints:VecStack
	
	Method New(x:Float, y:Float, points:VecStack = New VecStack())
		Super.New(x, y)
		Self.angle = 0
		Self.points = points
		Self.offset = New Vec2()
		Self.edges = New VecStack()
		Self.normals = New VecStack()
		Self.calcPoints = New VecStack()
		Self.bounds = New Rectangle();
		Self.Recalc()
	End
	
	Method ScalePolygon:Polygon(x:Float, y:Float)
		Local i:Int
		Local points:VecStack = Self.points
		Local edges:VecStack = Self.edges
		Local normals:VecStack = Self.normals
		Local len:Int = points.Length()
		
		For i = 0 To len - 1
			points.Get(i).Scale(x, y)
			edges.Get(i).Scale(x, y)
			normals.Get(i).Scale(x, y)
		Next
	End
	
	Method SetPoints:Polygon (points:VecStack)
		Self.points = points
		Self.Recalc()
		
		Return Self
	End
	
	Method SetAngle:Polygon (angle:Float)
		Self.angle = angle
		Self.Recalc()
		
		Return Self
	End
	
	Method SetOffset:Polygon (offset:Vec2)
		Self.offset = offset
		Self.Recalc()
		
		Return Self
	End
	
	Method RotatePolygon:Polygon (angle:Float)
		Local points:VecStack = Self.points
		Local len:Int = points.Length()
		Local i:Int
		
		For i = 0 To len - 1
			points.Get(i).Rotate(angle)
		Next
		Self.Recalc()
		
		Return Self
	End
	
	Method Translate:Polygon (x:Float, y:Float)
		Local points:VecStack = Self.points
		Local len:Int = points.Length()
		Local i:Int = 0
		
		For i = 0 To len - 1
			points.Get(i).x += x
			points.Get(i).y += y
		Next
		
		Self.Recalc()
		
		Return Self
	End
	
	Method Recalc:Polygon ()
		Local edges:VecStack = Self.edges.Wipe()
		Local calcPoints:VecStack = Self.calcPoints.Wipe()
		Local normals:VecStack = Self.normals.Wipe()
		Local points:VecStack = Self.points
		Local offset:Vec2 = Self.offset
		Local angle:Float = Self.angle
		Local len:Int = points.Length()
		Local i:Int
		For i = 0 To len - 1
			Local calcPoint:Vec2 = points.Get(i).Clone()
			calcPoint.x += offset.x
			calcPoint.y += offset.y
			If (angle <> 0)
				calcPoint.Rotate(angle)
			Endif
			calcPoints.Push(calcPoint)
		Next
		For i = 0 To len - 1
			Local p1:Vec2 = calcPoints.Get(i)
			Local p2:Vec2
			If (i < len - 1)
				p2 = calcPoints.Get(i + 1)
			Else
				p2 = calcPoints.Get(0)
			Endif
			Local e:Vec2 = New Vec2().Copy(p2).Sub(p1)
			Local n:Vec2 = New Vec2().Copy(e).Perp().Normalize()
			edges.Push(e)
			normals.Push(n)
		Next
		Return Self
	End
	
	Method GetBounds:Rectangle ()
		Local len:Int = calcPoints.Length()
		xMin = calcPoints.Get(0).x + Self.x
		yMin = calcPoints.Get(0).y + Self.y
		xMax = xMin
		yMax = yMin
		Local x:Float
		Local y:Float
		Local i:Int
		
		For i = 0 To len - 1
			x = calcPoints.Get(i).x + Self.x
			y = calcPoints.Get(i).y + Self.y
			If (x < xMin)
				xMin = x
			Endif
			If (x > xMax)
				xMax = x
			Endif
			If (y < yMin)
				yMin = y
			Endif
			If (y > yMax)
				yMax = y
			Endif
		Next
		
		bounds.x = xMin
		bounds.y = yMin
		bounds.width = xMax - xMin
		bounds.height = yMax - yMin

		Return bounds
	End
	
	Method GetPosition:Vec2 ()
		Return Self
	End
	
	Method SetPosition:Void (x:Float, y:Float)
		Self.Set(x, y)
	End
	
	Method SetPosition:Void (vec:Vec2)
		Self.Copy(vec)
	End
	
	Method GetType:Int ()
		Return ShapeType.POLYGON
	End
	
	Method DebugDraw:Void ()
		PushMatrix()
		mojo.Translate(x, y)
		DrawPoint(0, 0)
		Local p:Vec2
		Local n:Vec2
		For Local i:Int = 0 To calcPoints.Length() - 1
			If (i > 0)
				n = calcPoints.Get(i - 1)
			Else
				n = calcPoints.Get(i)
			Endif
			p = calcPoints.Get(i)
			
			DrawLine(n.x, n.y, p.x, p.y)
		Next
		If (calcPoints.Length() > 1)
			DrawLine(p.x, p.y, calcPoints.Get(0).x, calcPoints.Get(0).y)
		Endif
		PopMatrix()
	End
End