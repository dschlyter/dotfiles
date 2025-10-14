javascript:(function() {
  /* Paste this into a browser bookmark for easy access! Code conservatively here, no arrow functions or one-line comments, as that will break paste-ability. */
  var doggos = [
    "https://static.vecteezy.com/system/resources/thumbnails/041/642/908/small_2x/ai-generated-cute-cat-reaching-up-with-paw-on-transparent-background-png.png",
    "https://static.vecteezy.com/system/resources/thumbnails/048/739/390/small_2x/cat-relaxing-isolated-against-a-transparent-background-png.png",
    "https://static.vecteezy.com/system/resources/previews/045/914/109/non_2x/happy-bernese-mountain-dog-wearing-a-hawaiian-shirt-transparent-background-png.png",
    "https://www.seekpng.com/png/detail/137-1376540_happy-dog-png-dog-with-sunglasses-transparent.png",
    "https://th.bing.com/th/id/OIP.psjzMVsafow2MY16pbkCRgHaHa?w=181&h=181&c=7&r=0&o=7&pid=1.7&rm=3",
    "https://png.pngtree.com/png-clipart/20231020/original/pngtree-happy-funny-cute-kitty-fluffy-cat-png-image_13374339.png",
    "https://png.pngtree.com/png-clipart/20230927/original/pngtree-happy-cat-smiling-cat-png-image_13141575.png",
    "https://www.pngall.com/wp-content/uploads/10/Dog-Pet-PNG-Pic.png"
  ];

  var N = 40;
  var SIZE = 150;
  var W = window.innerWidth;
  var H = window.innerHeight;

  function rand(a, b) {
    return a + Math.random() * (b - a);
  }

  for (var i = 0; i < N; i++) {
    (function() {
      var img = document.createElement('img');
      img.src = doggos[Math.floor(Math.random() * doggos.length)];
      img.style.position = 'fixed';
      img.style.width = SIZE + 'px';
      img.style.height = 'auto';
      img.style.left = '0px';
      img.style.top = '0px';
      img.style.transform = 'translate(-50%, -50%)';
      img.style.zIndex = 9999999;
      img.style.pointerEvents = 'none';
      img.style.opacity = 1;
      document.body.appendChild(img);

      var sx = rand(W * 0.33, W * 0.66);
      var sy = H + SIZE * 0.5;
      var vx = rand(-H * 0.5, H * 0.5);
      var vy = -rand(H * 1.5, H * 3);
      var gravity = H * 3;
      var airResistance = 0.998;
      var duration = rand(2.0, 4.0);
      var startTime = performance.now();

      function step(t) {
        var elapsed = (t - startTime) / 1000;

        vy *= airResistance;
        var x = sx + vx * elapsed;
        var y = sy + vy * elapsed + 0.5 * gravity * elapsed * elapsed;

        if (elapsed > duration * 0.6) {
          img.style.opacity = Math.max(0, 1 - (elapsed - duration * 0.6) / (duration * 0.4));
        }

        if (y > H + SIZE || elapsed > duration) {
          if (img.parentNode) img.parentNode.removeChild(img);
          return;
        }

        if (x < SIZE / 2) x = SIZE / 2;
        if (x > W - SIZE / 2) x = W - SIZE / 2;

        img.style.left = x + 'px';
        img.style.top = y + 'px';

        requestAnimationFrame(step);
      }

      requestAnimationFrame(step);
    })();
  }
})();
