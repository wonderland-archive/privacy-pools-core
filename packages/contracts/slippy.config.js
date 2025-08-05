module.exports = [
  {
    ignores: ["src/contracts/verifiers/**/*.sol"],
    rules: {
      "explicit-types": "error",
      "id-denylist": "error",
      "imports-on-top": "error",
      "max-state-vars": "off",
      "naming-convention": "off",
      "no-console": "error",
      "no-default-visibility": "error",
      "no-duplicate-imports": "error",
      "no-empty-blocks": "error",
      "no-global-imports": "error",
      "no-tx-origin": "error",
      "no-uninitialized-immutable-references": "error",
      "no-unused-vars": "error",
      "private-vars": "off",
      "require-revert-reason": "error",
      "sort-imports": "off",
      "sort-modifiers": "error",
    },
  },
  {
    files: ["src/interfaces/**/*.sol"],
    rules: {
      "naming-convention": "off",
    },
  },
  {
    files: ["test/**/*.sol", "script/**/*.sol"],
    rules: {
      "require-revert-reason": "off",
      "no-console": "off",
    },
  },
];
