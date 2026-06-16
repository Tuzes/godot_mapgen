class_name HeightmapProcessingConfig
extends Resource

## Height thresholds defining tier boundaries (7 bands)
@export var thresholds: PackedFloat32Array = [0.30, 0.38, 0.42, 0.55, 0.70, 0.85, 1.00]

## Midpoint heights for each tier (snap targets after terracing)
@export var midpoints: PackedFloat32Array = [0.15, 0.34, 0.40, 0.485, 0.625, 0.775, 0.925]

## Tier colours matching HTML legend (deep-water → peak)
@export var tier_colors: Array[Color] = [
	Color(0.10196078431, 0.22745098039, 0.42352941176, 1.0),  # deep water  #1a3a6c
	Color(0.22745098039, 0.54901960784, 0.75294117647, 1.0),  # shallow     #3a8cc0
	Color(0.90980392157, 0.78431372549, 0.25098039216, 1.0),  # beach       #e8c840
	Color(0.35294117647, 0.61960784314, 0.29019607843, 1.0),  # grass       #5a9e4a
	Color(0.16470588235, 0.41568627451, 0.16470588235, 1.0),  # forest      #2a6a2a
	Color(0.47843137255, 0.22745098039, 0.66666666667, 1.0),  # mountain    #7a3aaa
	Color(0.60392156863, 0.35294117647, 0.80000000000, 1.0),  # peak        #9a5acc
]

## Horizontal water-plane height (normalised [0,1])
@export var water_level: float = 0.30

## Water-surface colour. RGB follows the HTML deep-water color; alpha makes the plane translucent.
@export var water_color: Color = Color(0.10196078431, 0.22745098039, 0.42352941176, 0.45)

## Cliff-face rock colour (yellow-gray)
@export var cliff_color: Color = Color(0.78, 0.73, 0.52, 1.0)

## Vertical drop applied to purple-tier heights so the mountain base
## sits flush with the dark-green terrace.
## Default = thresholds[4] - midpoints[4] = 0.70 - 0.625 = 0.075
## (purple lower bound minus dark-green platform height).
@export var mountain_drop: float = 0.075

## Horizontal scale applied by ScaleProcessor (XZ plane).
## 1.0 = original size, 2.0 = doubles map footprint on XZ.
@export var xy_scale: float = 1.0

## Vertical scale applied to non-mountain tiers (0-4: water → forest).
## Multiplies the heightmap value of those tiers in place.
@export var z_scale_low: float = 1.0

## Vertical scale applied to mountain tiers (5-6: purple).
## Multiplies the heightmap value of those tiers in place (around the dropped base).
@export var z_scale_high: float = 1.0


## Number of tier bands
func tier_count() -> int:
	return thresholds.size()
