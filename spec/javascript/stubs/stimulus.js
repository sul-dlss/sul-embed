// Stimulus is served from the stimulus-rails gem via importmap rather than node_modules, so it
// cannot be resolved when vitest imports a controller. This stands in for it, which is enough to
// exercise a controller's own methods. It is aliased to "@hotwired/stimulus" in vitest.config.ts.
export class Controller {}
