#!/usr/bin/env zsh
# =============================================================================
# Atuin ZSH Plugin - 历史记录同步工具的 ZSH 集成
# =============================================================================
# 此插件为 atuin 命令行历史记录工具提供 ZSH 集成功能
# AUTIN: installing the shell plugin 👉  https://docs.atuin.sh/guide/installation/#installing-the-shell-plugin

# -----------------------------------------------------------------------------
# 函数：初始化 atuin zsh 集成
# 功能：生成或更新 atuin 的 zsh 初始化脚本并加载
# 参数：
#   $1 - 目标文件路径
#   $2+ - 要执行的命令及其参数
# -----------------------------------------------------------------------------
_atuin_init_zsh_integration() {
  # 启用本地作用域和严格模式
  builtin emulate -L zsh
  setopt LOCAL_OPTIONS  #WARN_CREATE_GLOBAL
  
  # 参数验证和解析
  local -r target_file="${1:?Target file path is required}"
  shift
  local -r command_name="${1:?Command name is required}"
  
  # 检查命令是否存在
  if (( ! ${+commands[${command_name}]} )); then
    print -u2 "Warning: Command '${command_name}' not found in PATH"
    return 1
  fi
  
  # 检查是否需要重新生成初始化脚本
  # 条件：目标文件不存在、为空、或者比命令二进制文件旧
  if [[ ! -s "${target_file}" || "${target_file}" -ot "${commands[${command_name}]}" ]]; then
    print -u2 "Generating atuin zsh integration script..."
    
    # 生成初始化脚本，使用 >! 强制覆盖
    if ! "${@}" >! "${target_file}"; then
      print -u2 "Error: Failed to generate atuin integration script"
      return 1
    fi
    
    # 编译 zsh 脚本以提高加载速度
    # -U: 不检查别名, -R: 递归编译
    if ! zcompile -UR "${target_file}" 2>/dev/null; then
      print -u2 "Warning: Failed to compile ${target_file}"
    fi
    
    print -u2 "Successfully generated and compiled atuin integration"
  fi
  
  # 加载初始化脚本
  if [[ -r "${target_file}" ]]; then
    source "${target_file}"
  else
    print -u2 "Error: Cannot read atuin integration file: ${target_file}"
    return 1
  fi
}

# =============================================================================
# 主执行部分
# =============================================================================

# 初始化 atuin zsh 集成
_atuin_init_zsh_integration "${0:h}/atuin--zsh.zsh" atuin init zsh || {
  print -u2 "Failed to initialize atuin zsh integration"
  return 1
}

# 清理函数（可选）
if [[ -n "${ZIM_PLUGIN_CLEANUP:-}" ]]; then
  unfunction _atuin_init_zsh_integration 2>/dev/null
fi
