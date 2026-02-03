USING: accessors kernel multiline pbrt sequences tools.test ;

IN: pbrt.tests

{ { T{ pbrt-world-begin } T{ pbrt-world-end } } }
[ "WorldBegin WorldEnd" pbrt> ] unit-test

{ { T{ pbrt-attribute-begin } T{ pbrt-attribute-end } } }
[ "AttributeBegin AttributeEnd" pbrt> ] unit-test

{ { T{ pbrt-transform-begin } T{ pbrt-transform-end } } }
[ "TransformBegin TransformEnd" pbrt> ] unit-test

{ { T{ pbrt-reverse-orientation } } }
[ "ReverseOrientation" pbrt> ] unit-test

{ { T{ pbrt-identity } } }
[ "Identity" pbrt> ] unit-test

{ { T{ pbrt-world-begin } } }
[ "# this is a comment\nWorldBegin" pbrt> ] unit-test

{ { T{ pbrt-world-begin } T{ pbrt-world-end } } }
[ "WorldBegin # comment\nWorldEnd" pbrt> ] unit-test

{ 1 } [ "Translate 1 2 3" pbrt> first x>> ] unit-test
{ 2 } [ "Translate 1 2 3" pbrt> first y>> ] unit-test
{ 3 } [ "Translate 1 2 3" pbrt> first z>> ] unit-test

{ 2 } [ "Scale 2 2 2" pbrt> first x>> ] unit-test

{ 90 } [ "Rotate 90 0 1 0" pbrt> first angle>> ] unit-test
{ 1 } [ "Rotate 90 0 1 0" pbrt> first y>> ] unit-test

{ 3 } [ "LookAt 3 4 1.5 0.5 0.5 0 0 0 1" pbrt> first eye-x>> ] unit-test
{ 4 } [ "LookAt 3 4 1.5 0.5 0.5 0 0 0 1" pbrt> first eye-y>> ] unit-test
{ 1.5 } [ "LookAt 3 4 1.5 0.5 0.5 0 0 0 1" pbrt> first eye-z>> ] unit-test
{ 1 } [ "LookAt 3 4 1.5 0.5 0.5 0 0 0 1" pbrt> first up-z>> ] unit-test

{ 16 }
[ "Transform [1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1]" pbrt> first matrix>> length ] unit-test

{ "perspective" }
[ "Camera \"perspective\" \"float fov\" [45]" pbrt> first type>> ] unit-test

{ 1 }
[ "Camera \"perspective\" \"float fov\" [45]" pbrt> first params>> length ] unit-test

{ "float" }
[ "Camera \"perspective\" \"float fov\" [45]" pbrt> first params>> first type>> ] unit-test

{ "fov" }
[ "Camera \"perspective\" \"float fov\" [45]" pbrt> first params>> first name>> ] unit-test

{ { 45 } }
[ "Camera \"perspective\" \"float fov\" [45]" pbrt> first params>> first values>> ] unit-test

{ "image" }
[ "Film \"image\" \"integer xresolution\" [1280] \"integer yresolution\" [720]" pbrt> first type>> ] unit-test

{ 2 }
[ "Film \"image\" \"integer xresolution\" [1280] \"integer yresolution\" [720]" pbrt> first params>> length ] unit-test

{ "sphere" }
[ "Shape \"sphere\" \"float radius\" [1]" pbrt> first type>> ] unit-test

{ "matte" }
[ "Material \"matte\" \"rgb Kd\" [0.5 0.5 0.5]" pbrt> first type>> ] unit-test

{ { 0.5 0.5 0.5 } }
[ "Material \"matte\" \"rgb Kd\" [0.5 0.5 0.5]" pbrt> first params>> first values>> ] unit-test

{ "checks" }
[ "Texture \"checks\" \"spectrum\" \"checkerboard\"" pbrt> first name>> ] unit-test

{ "spectrum" }
[ "Texture \"checks\" \"spectrum\" \"checkerboard\"" pbrt> first value-type>> ] unit-test

{ "checkerboard" }
[ "Texture \"checks\" \"spectrum\" \"checkerboard\"" pbrt> first class>> ] unit-test

{ "gold" }
[ "MakeNamedMaterial \"gold\" \"string type\" \"metal\"" pbrt> first name>> ] unit-test

{ "gold" }
[ "NamedMaterial \"gold\"" pbrt> first name>> ] unit-test

{ "point" }
[ "LightSource \"point\" \"rgb I\" [1 1 1]" pbrt> first type>> ] unit-test

{ "diffuse" }
[ "AreaLightSource \"diffuse\" \"rgb L\" [10 10 10]" pbrt> first type>> ] unit-test

{ "other.pbrt" }
[ "Include \"other.pbrt\"" pbrt> first filename>> ] unit-test

{ "sphere1" }
[ "ObjectBegin \"sphere1\"" pbrt> first name>> ] unit-test

{ { T{ pbrt-object-end } } }
[ "ObjectEnd" pbrt> ] unit-test

{ "sphere1" }
[ "ObjectInstance \"sphere1\"" pbrt> first name>> ] unit-test

{ "camera" }
[ "CoordinateSystem \"camera\"" pbrt> first name>> ] unit-test

{ "camera" }
[ "CoordSysTransform \"camera\"" pbrt> first name>> ] unit-test

{ "fog" }
[ "MediumInterface \"fog\" \"air\"" pbrt> first interior>> ] unit-test

{ "air" }
[ "MediumInterface \"fog\" \"air\"" pbrt> first exterior>> ] unit-test

{ "fog" }
[ "MakeNamedMedium \"fog\" \"string type\" \"homogeneous\"" pbrt> first name>> ] unit-test

{ { "output.exr" } }
[ "Film \"image\" \"string filename\" \"output.exr\"" pbrt> first params>> first values>> ] unit-test

{ 3 }
[
    "Camera \"perspective\" \"float fov\" [45]\nWorldBegin\nWorldEnd"
    pbrt> length
] unit-test

{ -1 }
[ "Translate -1 0 0" pbrt> first x>> ] unit-test

{ "WorldBegin\n" }
[ { T{ pbrt-world-begin } } >pbrt ] unit-test

{ "WorldEnd\n" }
[ { T{ pbrt-world-end } } >pbrt ] unit-test

{ "Identity\n" }
[ { T{ pbrt-identity } } >pbrt ] unit-test

{ "ReverseOrientation\n" }
[ { T{ pbrt-reverse-orientation } } >pbrt ] unit-test

{ "Translate 1 2 3\n" }
[ { T{ pbrt-translate { x 1 } { y 2 } { z 3 } } } >pbrt ] unit-test

{ "Scale 2 2 2\n" }
[ { T{ pbrt-scale { x 2 } { y 2 } { z 2 } } } >pbrt ] unit-test

{ "Rotate 90 0 1 0\n" }
[ { T{ pbrt-rotate { angle 90 } { x 0 } { y 1 } { z 0 } } } >pbrt ] unit-test

{ "Camera \"perspective\"\n" }
[ { T{ pbrt-camera { type "perspective" } { params { } } } } >pbrt ] unit-test

{ "Include \"scene.pbrt\"\n" }
[ { T{ pbrt-include { filename "scene.pbrt" } } } >pbrt ] unit-test

{
    {
        T{ pbrt-look-at
            { eye-x 3 } { eye-y 4 } { eye-z 1.5 }
            { look-x 0.5 } { look-y 0.5 } { look-z 0 }
            { up-x 0 } { up-y 0 } { up-z 1 }
        }
        T{ pbrt-camera
            { type "perspective" }
            { params {
                T{ pbrt-param { type "float" } { name "fov" } { values { 45 } } }
            } }
        }
        T{ pbrt-world-begin }
        T{ pbrt-light-source
            { type "distant" }
            { params {
                T{ pbrt-param
                    { type "point" } { name "from" }
                    { values { -30 40 100 } }
                }
            } }
        }
        T{ pbrt-attribute-begin }
        T{ pbrt-material
            { type "matte" }
            { params {
                T{ pbrt-param
                    { type "rgb" } { name "Kd" }
                    { values { 0.5 0.5 0.5 } }
                }
            } }
        }
        T{ pbrt-shape
            { type "sphere" }
            { params {
                T{ pbrt-param
                    { type "float" } { name "radius" }
                    { values { 1 } }
                }
            } }
        }
        T{ pbrt-attribute-end }
        T{ pbrt-world-end }
    }
}
[
    "LookAt 3 4 1.5  0.5 0.5 0  0 0 1
Camera \"perspective\" \"float fov\" [45]
WorldBegin
  # A distant light
  LightSource \"distant\" \"point from\" [-30 40 100]
  AttributeBegin
    Material \"matte\" \"rgb Kd\" [0.5 0.5 0.5]
    Shape \"sphere\" \"float radius\" [1]
  AttributeEnd
WorldEnd" pbrt>
] unit-test

CONSTANT: killeroo-simple [=[
LookAt 400 20 30   0 63 -110   0 0 1
Rotate -5 0 0 1
Camera "perspective" "float fov" [39]
Film "image"
"integer xresolution" [700] "integer yresolution" [700]
    "string filename" "killeroo-simple.exr"

# zoom in by feet
# "integer xresolution" [1500] "integer yresolution" [1500]
#	"float cropwindow" [ .34 .49  .67 .8 ]

Sampler "halton" "integer pixelsamples" [8]

Integrator "path"

WorldBegin

AttributeBegin
Material "matte" "color Kd" [0 0 0]
Translate 150 0  20
Translate 0 120 0
AreaLightSource "area"  "color L" [2000 2000 2000] "integer nsamples" [8]
Shape "sphere" "float radius" [3]
AttributeEnd


AttributeBegin
  Material "matte" "color Kd" [.5 .5 .8]
  Translate 0 0 -140
Shape "trianglemesh" "point P" [ -1000 -1000 0 1000 -1000 0 1000 1000 0 -1000 1000 0 ]
      "float uv" [ 0 0 5 0 5 5 0 5 ]
	"integer indices" [ 0 1 2 2 3 0]
Shape "trianglemesh" "point P" [ -400 -1000 -1000   -400 1000 -1000   -400 1000 1000 -400 -1000 1000 ]
      "float uv" [ 0 0 5 0 5 5 0 5 ]
        "integer indices" [ 0 1 2 2 3 0]
AttributeEnd

AttributeBegin
Scale .5 .5 .5
Rotate -60 0 0 1
    Material "plastic" "color Kd" [.4 .2 .2] "color Ks" [.5 .5 .5]
        "float roughness" [.025]
Translate 100 200 -140
    Include "geometry/killeroo.pbrt"
    Material "plastic" "color Ks" [.3 .3 .3] "color Kd" [.4 .5 .4]
        "float roughness" [.15]
Translate -200 0 0
    Include "geometry/killeroo.pbrt"

AttributeEnd
WorldEnd
]=]

{ 31 } [ killeroo-simple pbrt> length ] unit-test

{ 400 } [ killeroo-simple pbrt> first eye-x>> ] unit-test
{ -110 } [ killeroo-simple pbrt> first look-z>> ] unit-test

{ "perspective" } [ killeroo-simple pbrt> third type>> ] unit-test
{ 39 } [ killeroo-simple pbrt> third params>> first values>> first ] unit-test

{ 3 } [ killeroo-simple pbrt> fourth params>> length ] unit-test
{ "killeroo-simple.exr" }
[ killeroo-simple pbrt> fourth params>> third values>> first ] unit-test

{ 3 }
[ killeroo-simple pbrt> [ pbrt-shape? ] filter length ] unit-test

{ "sphere" }
[ killeroo-simple pbrt> [ pbrt-shape? ] filter first type>> ] unit-test

{ 12 }
[
    killeroo-simple pbrt>
    [ pbrt-shape? ] filter second
    params>> first values>> length
] unit-test

{ 2 }
[ killeroo-simple pbrt> [ pbrt-include? ] filter length ] unit-test

{ "geometry/killeroo.pbrt" }
[ killeroo-simple pbrt> [ pbrt-include? ] filter first filename>> ] unit-test

{ t } [ killeroo-simple pbrt> dup >pbrt pbrt> = ] unit-test

{ "string" }
[ "Option \"string\" \"bool disablepixeljitter\" true" pbrt> first type>> ] unit-test

{ "srgb" }
[ "ColorSpace \"srgb\"" pbrt> first name>> ] unit-test

{ 0 }
[ "TransformTimes 0 1" pbrt> first start>> ] unit-test

{ 1 }
[ "TransformTimes 0 1" pbrt> first end>> ] unit-test

{ "StartTime" }
[ "ActiveTransform StartTime" pbrt> first mode>> ] unit-test

{ "EndTime" }
[ "ActiveTransform EndTime" pbrt> first mode>> ] unit-test

{ "All" }
[ "ActiveTransform All" pbrt> first mode>> ] unit-test

{ "geometry/scene.pbrt" }
[ "Import \"geometry/scene.pbrt\"" pbrt> first filename>> ] unit-test

{ "shape" }
[ "Attribute \"shape\" \"float alpha\" 1" pbrt> first target>> ] unit-test

{ 1 }
[ "Attribute \"shape\" \"float alpha\" 1" pbrt> first params>> length ] unit-test

{ "ColorSpace \"rec2020\"\n" }
[ { T{ pbrt-color-space { name "rec2020" } } } >pbrt ] unit-test

{ "TransformTimes 0 1\n" }
[ { T{ pbrt-transform-times { start 0 } { end 1 } } } >pbrt ] unit-test

{ "ActiveTransform All\n" }
[ { T{ pbrt-active-transform { mode "All" } } } >pbrt ] unit-test

{ "Import \"scene.pbrt\"\n" }
[ { T{ pbrt-import { filename "scene.pbrt" } } } >pbrt ] unit-test
