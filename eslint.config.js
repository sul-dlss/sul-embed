import js from "@eslint/js"
import globals from "globals"
import reactPlugin from "eslint-plugin-react"
import reactHooks from "eslint-plugin-react-hooks"
import jsxA11y from "eslint-plugin-jsx-a11y"
import testingLibrary from "eslint-plugin-testing-library"
import jestDom from "eslint-plugin-jest-dom"

export default [
  {
    ignores: [
      "vendor/**",
      "public/**",
      "tmp/**",
      "app/javascript/controllers/**"
    ]
  },

  js.configs.recommended,
  reactPlugin.configs.flat.recommended,
  reactPlugin.configs.flat["jsx-runtime"],
  reactHooks.configs.flat.recommended,
  jsxA11y.flatConfigs.recommended,

  {
    files: ["**/*.{js,jsx}"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
      globals: {
        ...globals.browser
      },
      parserOptions: {
        ecmaFeatures: {
          jsx: true
        }
      }
    },
    settings: {
      react: {
        version: "19"
      }
    },
    rules: {
      "no-console": "off",
      "no-underscore-dangle": "off",
      "sort-keys": ["error", "asc", { caseSensitive: false, natural: false }]
    }
  },

  {
    files: ["**/*.test.{js,jsx}", "spec/**/*.{js,jsx}"],
    plugins: {
      "testing-library": testingLibrary,
      "jest-dom": jestDom
    },
    rules: {
      ...testingLibrary.configs.react.rules,
      ...jestDom.configs["flat/recommended"].rules
    },
    languageOptions: {
      globals: {
        ...globals.browser,
        vi: true,
        page: true
      }
    }
  }
]
