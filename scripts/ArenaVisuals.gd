extends Node2D

## 竞技场视觉效果：画地板和墙壁
func _draw():
	# 地板 (竞技场内部)
	draw_rect(Rect2(-540, -390, 1080, 780), Color(0.18, 0.18, 0.25))
	# 四面墙壁
	draw_rect(Rect2(-560, -500, 20, 1000), Color(0.45, 0.1, 0.05))   # 左
	draw_rect(Rect2(540, -500, 20, 1000), Color(0.45, 0.1, 0.05))    # 右
	draw_rect(Rect2(-550, -410, 1100, 20), Color(0.45, 0.1, 0.05))  # 上
	draw_rect(Rect2(-550, 390, 1100, 20), Color(0.45, 0.1, 0.05))   # 下
