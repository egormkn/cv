(function () {
  pdf2htmlEX.Viewer.prototype.minScale = 1 / 4;
  pdf2htmlEX.Viewer.prototype.maxScale = 4;

  pdf2htmlEX.Viewer.prototype.fit = function () {
    var pageIdx = this.cur_page_idx;
    var scale = Math.min(
      this.container.clientWidth / this.pages[pageIdx].width(),
      this.container.clientHeight / this.pages[pageIdx].height()
    );
    this.minScale = Math.min(this.minScale, scale);
    this.maxScale = Math.max(this.maxScale, scale);
    this.rescale(scale, true);
    this.scroll_to(pageIdx)
  };

  pdf2htmlEX.Viewer.prototype.zoom = function (zoomFactor, center) {
    var scale = Math.max(this.minScale, Math.min(this.maxScale, this.scale * zoomFactor));
    this.rescale(scale, false, center || [0, 0]);
  };

  var init_after_loading_content = pdf2htmlEX.Viewer.prototype.init_after_loading_content;
  pdf2htmlEX.Viewer.prototype.init_after_loading_content = function () {
    init_after_loading_content.apply(this, arguments);

    this.fit();

    var _this = this;

    this.container.addEventListener('wheel', function (ev) {
      if (!ev.ctrlKey) return;
      ev.preventDefault();
      ev.stopPropagation();

      var pageRect = _this.pages[_this.cur_page_idx].page.getBoundingClientRect();
      var x = ev.clientX - pageRect.left;
      var y = ev.clientY - pageRect.top;

      _this.zoom(ev.deltaY < 0 ? 1.1 : 0.9, [x, y]);
    }, { passive: false });

    this.pinchEventCache = [];
    this.pinchPreviousDiff = -1;

    function pointerdownHandler(ev) {
      // The pointerdown event signals the start of a touch interaction.
      // This event is cached to support 2-finger gestures
      _this.pinchEventCache.push(ev);
    }

    function pointermoveHandler(ev) {
      // This function implements a 2-pointer pinch/zoom gesture.

      // Find this event in the cache and update its record with this event
      var index = _this.pinchEventCache.findIndex(
        (cachedEv) => cachedEv.pointerId === ev.pointerId,
      );
      if (index !== -1) _this.pinchEventCache[index] = ev;

      // If two pointers are down, check for pinch gestures
      if (_this.pinchEventCache.length === 2) {
        ev.preventDefault();
        ev.stopPropagation();
        // Calculate the distance between the two pointers
        var curDiff = Math.hypot(
          _this.pinchEventCache[0].clientX - _this.pinchEventCache[1].clientX,
          _this.pinchEventCache[0].clientY - _this.pinchEventCache[1].clientY,
        );

        var clientX = (_this.pinchEventCache[0].clientX + _this.pinchEventCache[1].clientX) / 2;
        var clientY = (_this.pinchEventCache[0].clientY + _this.pinchEventCache[1].clientY) / 2;
        var pageRect = _this.pages[_this.cur_page_idx].page.getBoundingClientRect();
        var x = clientX - pageRect.left;
        var y = clientY - pageRect.top;

        if (_this.pinchPreviousDiff > 0) {
          _this.zoom(curDiff / _this.pinchPreviousDiff, [x, y]);
        }

        // Cache the distance for the next move event
        _this.pinchPreviousDiff = curDiff;
      }
    }

    function pointerupHandler(ev) {
      // Remove this pointer from the cache
      var index = _this.pinchEventCache.findIndex(
        (cachedEv) => cachedEv.pointerId === ev.pointerId,
      );
      if (index !== -1) _this.pinchEventCache.splice(index, 1);

      // If the number of pointers down is less than two then reset diff tracker
      if (_this.pinchEventCache.length < 2) {
        _this.pinchPreviousDiff = -1;
      }
    }

    // Install event handlers for the pointer target
    this.container.addEventListener('pointerdown', pointerdownHandler);
    this.container.addEventListener('pointermove', pointermoveHandler, { passive: false });

    // Use same handler for pointer{up,cancel,out,leave} events since
    // the semantics for these events - in this app - are the same.
    this.container.addEventListener('pointerup', pointerupHandler);
    this.container.addEventListener('pointercancel', pointerupHandler);
    this.container.addEventListener('pointerout', pointerupHandler);
    this.container.addEventListener('pointerleave', pointerupHandler);
  }
})();
