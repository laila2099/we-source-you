import prettierPlugin from "eslint-plugin-prettier";

/** @type {import("eslint").ESLint.FlatConfig[]} */
export default [
  {
    files: ["*.js", "**/*.js"],
    languageOptions: {
      ecmaVersion: 2022, // لدعم optional chaining و nullish
      sourceType: "module",
      globals: {
        console: "readonly",
        process: "readonly",
        module: "writable",
        require: "readonly",
        __dirname: "readonly",
        __filename: "readonly"
      }
    },
    rules: {
      "no-trailing-spaces": "error",
      "no-unused-vars": ["warn"],
      "require-jsdoc": "off"
      // إزالة "indent" و "comma-dangle" → Prettier يتولى formatting
    }
  },
  {
    files: ["*.js", "**/*.js"],
    plugins: {
      prettier: prettierPlugin
    },
    rules: {
      "prettier/prettier": [
        "error",
        {
          semi: true,
          trailingComma: "all",
          singleQuote: true,
          printWidth: 100,
          tabWidth: 2,
          bracketSpacing: true
        }
      ]
    }
  }
];
