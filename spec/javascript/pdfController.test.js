import PdfController from "../../app/javascript/controllers/pdf_controller.js"

const ISSUE_1 = "https://stacks.stanford.edu/file/xr775nq8354/issue-1.pdf"
const ISSUE_2 = "https://stacks.stanford.edu/file/xr775nq8354/issue-2.pdf"

const buildController = (values = {}) => {
  const controller = Object.create(PdfController.prototype)
  controller.element = document.createElement("div")
  Object.entries(values).forEach(([name, value]) => {
    controller[`${name}Value`] = value
    controller[`has${name[0].toUpperCase()}${name.slice(1)}Value`] = true
  })
  return controller
}

const show = (controller, fileUri) => {
  controller.show({ detail: { fileUri } })
  const data = controller.element.querySelector("object")?.getAttribute("data")
  return data && new URL(data)
}

describe("PdfController", () => {
  describe("show", () => {
    it("opens the PDF at the start when no page was requested", () => {
      const controller = buildController()

      expect(show(controller, ISSUE_1).hash).toEqual("")
    })

    it("opens any PDF to the page when the page names no file", () => {
      const controller = buildController({ page: 3 })

      expect(show(controller, ISSUE_1).hash).toEqual("#page=3")
      expect(show(controller, ISSUE_2).hash).toEqual("#page=3")
    })

    it("opens only the PDF the page belongs to at that page", () => {
      const controller = buildController({ page: 3, pageUri: ISSUE_2 })

      expect(show(controller, ISSUE_2).hash).toEqual("#page=3")
      expect(show(controller, ISSUE_1).hash).toEqual("")
    })

    it("ignores PDFs meant for another element", () => {
      const controller = buildController({ uri: ISSUE_1 })

      expect(show(controller, ISSUE_2)).toBeUndefined()
      expect(show(controller, ISSUE_1).href).toMatch(ISSUE_1)
    })
  })
})
