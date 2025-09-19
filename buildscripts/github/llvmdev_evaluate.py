import argparse
import json
import sys

def evaluate(event_name, platform, recipe, run_stage):
    """
    Evaluates the platform and recipe to determine the build matrix.
    """
    matrix = {}
    include_matrix = []

    # Get the runner for the specified platform
    runner = get_runner(platform)

    # All platforms run all recipes by default
    if event_name == "workflow_dispatch":
        # Handle the special "all" option for platform
        if platform == "all":
            platforms = ["linux-64", "linux-aarch64", "linux-s390x", "osx-64", "osx-arm64", "win-64"]
        else:
            platforms = [platform]

        # Handle the special "all" option for recipe
        if recipe == "all":
            recipes = ["llvmdev", "llvmdev_for_wheel"]
        else:
            recipes = [recipe]

        for p in platforms:
            for r in recipes:
                include_matrix.append({"runner": get_runner(p), "platform": p, "recipe": r})
    else:
        # Default behavior for pull requests or other events
        # You can add logic here to filter based on paths or other conditions
        platforms = ["linux-64", "linux-aarch64", "linux-s390x", "osx-64", "osx-arm64", "win-64"]
        recipes = ["llvmdev", "llvmdev_for_wheel"]
        for p in platforms:
            for r in recipes:
                include_matrix.append({"runner": get_runner(p), "platform": p, "recipe": r})

    # Filter out combinations that don't match the run_stage
    if run_stage != "all":
        filtered_matrix = []
        for item in include_matrix:
            if item["platform"] == "linux-s390x" and item["recipe"] == "llvmdev_for_wheel":
                # Only include this combination if it's an s390x build
                filtered_matrix.append(item)
            # All other builds are single-stage, so they only run with the 'all' stage
            elif run_stage == "all":
                filtered_matrix.append(item)
        include_matrix = filtered_matrix

    matrix["include"] = include_matrix
    print(json.dumps(matrix))


def get_runner(platform):
    """
    Returns the appropriate runner for a given platform.
    """
    if platform == "linux-64":
        return "ubuntu-24.04"
    elif platform == "linux-aarch64":
        return "ubuntu-24.04"
    elif platform == "linux-s390x":
        return "ubuntu-24.04"
    elif platform == "osx-64":
        return "macos-14"
    elif platform == "osx-arm64":
        return "macos-14"
    elif platform == "win-64":
        return "windows-2022"
    else:
        # Default to a safe runner for any unknown platforms
        return "ubuntu-24.04"


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--event-name", required=True)
    parser.add_argument("--platform", required=True)
    parser.add_argument("--recipe", required=True)
    parser.add_argument("--run-stage", required=False, default="all")
    args = parser.parse_args()
    
    evaluate(args.event_name, args.platform, args.recipe, args.run_stage)
