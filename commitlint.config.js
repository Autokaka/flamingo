module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "type-enum": [
      2,
      "always",
      [
        "feat", // 新特性
        "fix", // 修复问题
        "docs", // 文档修改
        "perf", // 提升性能的修改
        "style", // 代码格式修改, 注意不是 css 修改
        "refactor", // 代码重构
        "test", // 测试用例修改
        "chore", // 其他修改, 比如构建流程, 依赖管理.
        "revert", // 代码回滚
      ],
    ],
    "subject-full-stop": [0, "never"], // subject结尾不能有句号
    "subject-case": [0, "never"],
  },
};
