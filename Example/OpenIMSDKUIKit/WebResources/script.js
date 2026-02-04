'use strict';
var barHint = '向右滑动填充拼图';

window.GlobalCaptcha = {
    background: null,
    puzzle: null,
    h: 0,
}
var captchaJson = null;

var _iosReady = false;
var _iosBridge = null;
var _iosCallbacks = [];

// 辅助函数：添加日志到页面
function appendLog(text) {
    var logDiv = document.getElementById('log');
    logDiv.innerHTML += text + '<br/>';
}

function cleanMsg() {
    document.getElementById('msg').innerHTML = ''
}

function initIOSBridge(callback) {
    if (_iosReady) {
        callback(_iosBridge);
    } else {
        _iosCallbacks.push(callback);

        if (!window.WKWVJBCallbacks) {
            window.WKWVJBCallbacks = [];
        }

        window.WKWVJBCallbacks.push((bridge) => {
            _iosBridge = bridge;
            _iosReady = true;
            _iosCallbacks.forEach(cb => cb(bridge));
            _iosCallbacks = [];
        });

        window.webkit?.messageHandlers?.iOS_Native_InjectJavascript?.postMessage(null);
    }
}

var _createClass = function () {
    function defineProperties(target, props) {
        for (var i = 0; i < props.length; i++) {
            var descriptor = props[i];
            descriptor.enumerable = descriptor.enumerable || false;
            descriptor.configurable = true;
            if ("value" in descriptor) descriptor.writable = true;
            Object.defineProperty(target, descriptor.key, descriptor);
        }
    }

    return function (Constructor, protoProps, staticProps) {
        if (protoProps) defineProperties(Constructor.prototype, protoProps);
        if (staticProps) defineProperties(Constructor, staticProps);
        return Constructor;
    };
}();

function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
        throw new TypeError("Cannot call a class as a function");
    }
}

(function (window) {
    var l = 31,
        // 滑块边长
        r = 9,
        // 滑块半径
        w = 310,
        // canvas宽度
        h = 155,
        // canvas高度
        PI = Math.PI;
    var L = l + r * 2 + 3; // 滑块实际边长

    function base64ToImageData(base64, callback) {
        // 创建 Image 对象
        const img = new Image();

        // 图像加载完成后执行
        img.onload = function () {
            // 创建临时 Canvas
            const canvas = document.createElement('canvas');
            canvas.width = img.width;
            canvas.height = img.height;

            // 获取 Canvas 上下文并绘制图像
            const ctx = canvas.getContext('2d');
            ctx.drawImage(img, 0, 0);
            _draw2(ctx, 2, 16, 'clip');

            // 从 Canvas 获取 ImageData
            const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);

            // 通过回调返回 ImageData
            callback(imageData);
        };

        // 处理加载错误
        img.onerror = function () {
            console.log('图像加载失败');
            callback(null);
        };
        // 设置 Base64 源，触发加载
        img.src = base64;
    }

    function getRandomNumberByRange(start, end) {
        return Math.round(Math.random() * (end - start) + start);
    }

    function createCanvas(width, height) {
        var canvas = createElement('canvas');
        canvas.width = width;
        canvas.height = height;
        return canvas;
    }

    function createImg(onload) {
        var img = createElement('img');
        img.crossOrigin = "Anonymous";
        img.onload = onload;
        img.onerror = function () {
            //img.src = getRandomImg();
            //getCaptcha();
        };
        //img.src = getRandomImg();
        getCaptcha();
        return img;
    }

    function createElement(tagName, className) {
        var elment = document.createElement(tagName);
        elment.className = className;
        return elment;
    }

    //不支持element.classList方法的兼容写法（ie10及以下）
    if (!("classList" in document.documentElement)) {
        Object.defineProperty(HTMLElement.prototype, 'classList', {
            get: function () {
                var self = this;

                function update(fn) {
                    return function (value) {
                        var classes = self.className.split(/\s+/g),
                            index = classes.indexOf(value);

                        fn(classes, index, value);
                        self.className = classes.join(" ");
                    }
                }

                return {
                    add: update(function (classes, index, value) {
                        if (!~index) classes.push(value);
                    }),

                    remove: update(function (classes, index) {
                        if (~index) classes.splice(index, 1);
                    }),

                    toggle: update(function (classes, index, value) {
                        if (~index)
                            classes.splice(index, 1);
                        else
                            classes.push(value);
                    }),

                    contains: function (value) {
                        return !!~self.className.split(/\s+/g).indexOf(value);
                    },

                    item: function (i) {
                        return self.className.split(/\s+/g)[i] || null;
                    }
                };
            }
        });
    }

    function addClass(tag, className) {
        tag.classList.add(className);
    }

    function removeClass(tag, className) {
        tag.classList.remove(className);
    }

    function getRandomImg() {
        return 'https://picsum.photos/300/150/?image=' + getRandomNumberByRange(0, 1084);
    }

    // 绘制滑动块的白色边条
    function _draw(ctx, x, y, operation) {
        ctx.beginPath();
        ctx.moveTo(x, y);
        ctx.arc(x + l / 2, y - r + 2, r, 0.72 * PI, 2.26 * PI);
        ctx.lineTo(x + l, y);
        ctx.arc(x + l + r - 2, y + l / 2, r, 1.21 * PI, 2.78 * PI);
        ctx.lineTo(x + l, y + l);
        ctx.lineTo(x, y + l);
        ctx.arc(x + r - 2, y + l / 2, r + 0.4, 2.76 * PI, 1.24 * PI, true);
        ctx.lineTo(x, y);
        ctx.lineWidth = 2;
        ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
        ctx.strokeStyle = 'rgba(255, 255, 255, 0.7)';
        ctx.stroke();
        ctx[operation]();
        ctx.globalCompositeOperation = 'overlay';
    }

    // 绘制滑动块的白色边条
    function _draw2(ctx, x, y, operation) {
        ctx.beginPath();
        ctx.moveTo(x, y);
        ctx.arc(x + l / 2, y - r + 2, r, 0.72 * PI, 2.26 * PI);
        ctx.lineTo(x + l, y);
        ctx.arc(x + l + r - 2, y + l / 2, r, 1.21 * PI, 2.78 * PI);
        ctx.lineTo(x + l, y + l);
        ctx.lineTo(x, y + l);
        ctx.arc(x + r - 2, y + l / 2, r + 0.4, 2.76 * PI, 1.24 * PI, true);
        ctx.lineTo(x, y);
        ctx.lineWidth = 2;
        ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
        ctx.strokeStyle = 'rgba(255, 255, 255, 0.7)';
        ctx.stroke();
        ctx[operation]();
        ctx.globalCompositeOperation = 'overlay';
    }

    function sum(x, y) {
        return x + y;
    }

    function square(x) {
        return x * x;
    }

    var jigsaw = function () {
        function jigsaw(_ref) {
            var el = _ref.el,
                onSuccess = _ref.onSuccess,
                onFail = _ref.onFail,
                onRefresh = _ref.onRefresh;

            _classCallCheck(this, jigsaw);

            el.style.position = el.style.position || 'relative';
            this.el = el;
            this.onSuccess = onSuccess;
            this.onFail = onFail;
            this.onRefresh = onRefresh;
        }

        _createClass(jigsaw, [{
            key: 'init',
            value: function init() {
                this.initDOM();
                this.initImg();
                this.bindEvents();
            }
        }, {
            key: 'initDOM',
            value: function initDOM() {
                var canvas = createCanvas(w, h); // 画布
                var block = canvas.cloneNode(true); // 滑块
                var sliderContainer = createElement('div', 'sliderContainer');
                var refreshIcon = createElement('div', 'refreshIcon');
                var sliderMask = createElement('div', 'sliderMask');
                var slider = createElement('div', 'slider');
                var sliderIcon = createElement('span', 'sliderIcon');
                var text = createElement('span', 'sliderText');

                block.className = 'block';
                text.innerHTML = barHint;

                var el = this.el;
                el.appendChild(canvas);
                el.appendChild(block);
                slider.appendChild(sliderIcon);
                sliderMask.appendChild(slider);
                sliderContainer.appendChild(sliderMask);
                sliderContainer.appendChild(text);
                el.appendChild(sliderContainer);
                el.appendChild(refreshIcon);

                //20181113
                // 不支持assign方法的兼容写法
                if (typeof Object.assign != 'function') {
                    // Must be writable: true, enumerable: false, configurable: true
                    Object.defineProperty(Object, "assign", {
                        value: function assign(target, varArgs) { // .length of function is 2
                            'use strict';
                            if (target == null) { // TypeError if undefined or null
                                throw new TypeError('Cannot convert undefined or null to object');
                            }

                            var to = Object(target);

                            for (var index = 1; index < arguments.length; index++) {
                                var nextSource = arguments[index];

                                if (nextSource != null) { // Skip over if undefined or null
                                    for (var nextKey in nextSource) {
                                        // Avoid bugs when hasOwnProperty is shadowed
                                        if (Object.prototype.hasOwnProperty.call(nextSource, nextKey)) {
                                            to[nextKey] = nextSource[nextKey];
                                        }
                                    }
                                }
                            }
                            return to;
                        },
                        writable: true,
                        configurable: true
                    });
                }

                Object.assign(this, {
                    canvas: canvas,
                    block: block,
                    sliderContainer: sliderContainer,
                    refreshIcon: refreshIcon,
                    slider: slider,
                    sliderMask: sliderMask,
                    sliderIcon: sliderIcon,
                    text: text,
                    canvasCtx: canvas.getContext('2d'),
                    blockCtx: block.getContext('2d')
                });
            }
        }, {
            key: 'initImg',
            value: function initImg() {
                var _this = this;

                var img = createImg(function () {
                    _this.sliderContainer.className = 'sliderContainer';
                    _this.slider.style.left = 0;
                    _this.block.style.left = 0;
                    _this.sliderMask.style.width = 0;
                    _this.clean();

                    console.log("initImg")
                    _this.draw(); // 绘制拼图块
                    _this.canvasCtx.drawImage(img, 0, 0, w, h); // 绘制背景
                    //////////// _this.canvasCtx.drawImage(img, 0, 0, w, h);
                    _this.blockCtx.drawImage(img, 0, 0, w, h); // 绘制拼块
                    var y = _this.y - r * 2 - 1;

                    //getImageData方法和putImageData方法在IE9和IE10上，涉及到文件路径的跨域访问问题。
                    //   console.log('(x:'+_this.x+',y:'+_this.y+')');
                    if (navigator.userAgent.indexOf("MSIE") > -1) {
                        _this.block.style.marginLeft = '-' + (_this.x - 3) + 'px';//不抵边，空3px
                    } else {
                        //var ImageData = _this.blockCtx.getImageData(_this.x - 3, y, L, L);
                        _this.block.width = L;
                        //_this.blockCtx.putImageData(ImageData, 0, y);
                        base64ToImageData(captchaJson.puzzle, function (imageData) { // 绘制小拼块
                            if (imageData) {
                                //console.log('成功获取 ImageData:', imageData.width, 'x', imageData.height);
                                //appendLog('成功获取 ImageData:', imageData.width, 'x', imageData.height);
                                // 在这里可以对 imageData 进行处理
                                _this.blockCtx.putImageData(imageData, 0, y + 3);
                            }
                        });
                    }

                });
                this.img = img;
                window.GlobalCaptcha.background = img;
            }
        }, {
            key: 'draw',
            value: function draw() {
                // 随机创建滑块的位置
                this.x = getRandomNumberByRange(L + 10, w - (L + 10));
                //this.y = getRandomNumberByRange(10 + r * 2, h - (L + 10));
                this.y = captchaJson.h + 2
                //_draw(this.canvasCtx, this.x, this.y, 'fill');
                //_draw(this.blockCtx, this.x, this.y, 'clip');
            }
        }, {
            key: 'clean',
            value: function clean() {
                this.canvasCtx.clearRect(0, 0, w, h);
                this.blockCtx.clearRect(0, 0, w, h);
                this.block.width = w;
            }
        }, {
            key: 'bindEvents',
            value: function bindEvents() {
                var _this2 = this;

                this.el.onselectstart = function () {
                    return false;
                };
                this.refreshIcon.onclick = function () {
                    appendLog("点击刷新")
                    _this2.reset();
                    typeof _this2.onRefresh === 'function' && _this2.onRefresh();
                };

                var originX = void 0,
                    originY = void 0,
                    trail = [],
                    isMouseDown = false;

                var handleDragStart = function handleDragStart(e) {
                    originX = e.clientX || e.touches[0].clientX;
                    originY = e.clientY || e.touches[0].clientY;
                    isMouseDown = true;
                };

                var handleDragMove = function handleDragMove(e) {
                    if (!isMouseDown) return false;
                    var eventX = e.clientX || e.touches[0].clientX;
                    var eventY = e.clientY || e.touches[0].clientY;
                    var moveX = eventX - originX;
                    var moveY = eventY - originY;
                    if (moveX < 0 || moveX + 38 >= w) return false;
                    _this2.slider.style.left = moveX + 'px';
                    var blockLeft = (w - 40 - 20) / (w - 40) * moveX;
                    _this2.block.style.left = blockLeft + 'px';

                    addClass(_this2.sliderContainer, 'sliderContainer_active');
                    _this2.sliderMask.style.width = moveX + 'px';
                    trail.push(moveY);
                };

                var handleDragEnd = function handleDragEnd(e) {
                    if (!isMouseDown) return false;
                    isMouseDown = false;
                    var eventX = e.clientX || e.changedTouches[0].clientX;
                    if (eventX == originX) return false;
                    removeClass(_this2.sliderContainer, 'sliderContainer_active');
                    _this2.trail = trail;

                    var _verify = _this2.verify(),
                        spliced = _verify.spliced,
                        verified = _verify.verified;

                    /*if (spliced) {
                        if (verified) {
                            addClass(_this2.sliderContainer, 'sliderContainer_success');
                            typeof _this2.onSuccess === 'function' && _this2.onSuccess();
                        } else {
                            addClass(_this2.sliderContainer, 'sliderContainer_fail');
                            _this2.text.innerHTML = '再试一次';
                            _this2.reset();
                        }
                    } else {
                        addClass(_this2.sliderContainer, 'sliderContainer_fail');
                        typeof _this2.onFail === 'function' && _this2.onFail();
                        setTimeout(function () {
                            _this2.reset();
                        }, 1000);
                    }*/
                };
                this.slider.addEventListener('mousedown', handleDragStart);// 鼠标开始滑动
                this.slider.addEventListener('touchstart', handleDragStart);// 鼠标开始滑动
                document.addEventListener('mousemove', handleDragMove);// 鼠标移动回调
                document.addEventListener('touchmove', handleDragMove);// 鼠标移动按下回调
                document.addEventListener('mouseup', handleDragEnd);// 鼠标滑动停止释放回调
                document.addEventListener('touchend', handleDragEnd);// 鼠标滑动释放回调
            }
        }, {
            key: 'verify',
            value: function verify() {
                var arr = this.trail; // 拖动时y轴的移动距离
                var average = arr.reduce(sum) / arr.length;
                var deviations = arr.map(function (x) {
                    return x - average;
                });
                var stddev = Math.sqrt(deviations.map(square).reduce(sum) / arr.length);
                var left = parseInt(this.block.style.left);
                login(left);
                return {
                    spliced: Math.abs(left - this.x) < 10,
                    verified: stddev !== 0 // 简单验证下拖动轨迹，为零时表示Y轴上下没有波动，可能非人为操作
                };
            }
        }, {
            key: 'reset',
            value: function reset() {
                this.sliderContainer.className = 'sliderContainer';
                this.slider.style.left = 0;
                this.block.style.left = 0;
                this.sliderMask.style.width = 0;
                this.clean();
                //this.img.src = getRandomImg();
                getCaptcha();
            }
        }]);

        return jigsaw;
    }();

    window.jigsaw = {
        init: function init(opts) {
            return new jigsaw(opts).init();
        }
    };
})(window);

//在页面上使用
jigsaw.init({
    el: document.getElementById('captcha'),
    onSuccess: function () {
        document.getElementById('msg').innerHTML = '登录成功！'
    },
    onFail: cleanMsg,
    onRefresh: cleanMsg
})

// 获取滑块数据
function getCaptcha() {
    initIOSBridge((bridge) => {
        bridge.callHandler('getCaptcha', "", (res) => {
        });
    });
}
``
function login(x) {
    initIOSBridge((bridge) => {
        appendLog("登录 = " + x)
        bridge.callHandler('login', {param: x}, (res) => {

        });
    })
}

this.initIOSBridge((bridge) => {
    bridge.registerHandler('onCaptcha', (repsjson) => {
        //appendLog(repsjson)
        captchaJson = JSON.parse(repsjson);
        window.GlobalCaptcha.background.src = captchaJson.bg;
    });
});

this.initIOSBridge((bridge) => {
    bridge.registerHandler('showMessageFromSwift', (data) => {
        appendLog(data);
        const {code, list} = data
        callback(code, list);
    });
});


// 禁用上下文菜单（长按菜单）
document.documentElement.style.webkitUserSelect = 'none';
document.documentElement.style.webkitTouchCallout = 'none';

// 禁止所有元素的长按事件
document.addEventListener('contextmenu', function (e) {
    e.preventDefault();
}, false);

// 禁止选择文本
document.addEventListener('selectstart', function (e) {
    e.preventDefault();
}, false);

appendLog("执行到最后行")