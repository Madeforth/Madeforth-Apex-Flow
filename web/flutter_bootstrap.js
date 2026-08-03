window._flutter = window._flutter || {};
window._flutter.buildConfig = {
  engineRevision: 'e4b8dca3f1b4ede4c30371002441c88c12187ed6',
  builds: [
    {
      compileTarget: 'dart2js',
      renderer: 'canvaskit',
      mainJsPath: 'main.dart.js',
    },
  ],
};

window.addEventListener('load', function () {
  window._flutter.loader.load({
    config: {
      renderer: 'canvaskit',
      useLocalCanvasKit: true,
    },
    onEntrypointLoaded: async function (engineInitializer) {
      const appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();
    },
  });
});
