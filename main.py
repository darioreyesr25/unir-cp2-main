import json
import subprocess

# Cache terraform outputs to avoid repeated calls during the MkDocs build.
_terraform_outputs_cache = None


def _load_terraform_outputs():
    global _terraform_outputs_cache
    if _terraform_outputs_cache is not None:
        return _terraform_outputs_cache

    try:
        # Run terraform in the terraform/ directory to keep outputs isolated.
        out = subprocess.check_output(
            ["terraform", "-chdir=terraform", "output", "-json"],
            stderr=subprocess.DEVNULL,
        )
        _terraform_outputs_cache = json.loads(out)
    except Exception:
        _terraform_outputs_cache = {}
    return _terraform_outputs_cache


def terraform_output(name: str, default=None):
    """Return the value for a Terraform output (via `terraform output -json`).

    This is used from MkDocs content through the mkdocs-macros-plugin.

    Example usage in markdown:
        {{ terraform_output('resource_group_name') }}
    """

    outputs = _load_terraform_outputs()
    output = outputs.get(name)
    if not output:
        return default

    value = output.get("value")
    return value if value is not None else default


def define_env(env):
    """Define macros for mkdocs-macros-plugin."""
    env.variables["terraform_output"] = terraform_output
