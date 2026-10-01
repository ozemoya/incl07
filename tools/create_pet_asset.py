"""Original grayscale transparent pet art by the project author."""
from PIL import Image, ImageDraw

s = 512
image = Image.new('RGBA', (s, s), (0, 0, 0, 0))
d = ImageDraw.Draw(image)
# Light shapes work well with BlendMode.modulate.
d.ellipse((85, 105, 225, 280), fill='#e8e8e8', outline='#525252', width=10)
d.ellipse((287, 105, 427, 280), fill='#e8e8e8', outline='#525252', width=10)
d.ellipse((72, 148, 440, 473), fill='#f2f2f2', outline='#525252', width=14)
d.ellipse((158, 254, 190, 294), fill='#333333')
d.ellipse((322, 254, 354, 294), fill='#333333')
d.ellipse((236, 310, 276, 343), fill='#6d6d6d')
d.arc((204, 319, 308, 393), 8, 172, fill='#474747', width=9)
d.ellipse((135, 318, 180, 343), fill='#d6d6d6')
d.ellipse((332, 318, 377, 343), fill='#d6d6d6')
image.save('assets/pet.png')
