import json
import subprocess

# Cache terraform outputs to avoid repeated calls during mkdocs build.
_terraform_outputs_cache = None


def _load_terraform_outputs():
    global _terraform_outputs_cache
    if _terraform_outputs_cache is not None:
        return _terraform_outputs_cache

    try:
        # Run terraform from the terraform/ directory so outputs are read from the right state.
        out = subprocess.check_output(
            ["terraform", "-chdir=terraform", "output", "-json"],
            stderr=subprocess.DEVNULL,
        )
        _terraform_outputs_cache = json.loads(out)
    except Exception:
        _terraform_outputs_cache = {}
    return _terraform_outputs_cache


def terraform_output(name: str, default=None):
    """Return a terraform output value for use in MkDocs templates."""

    outputs = _load_terraform_outputs()
    output = outputs.get(name)
    if not output:
        return default
    return output.get("value", default)


def define_env(env):
    env.variables["terraform_output"] = terraform_output
