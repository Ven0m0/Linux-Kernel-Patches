"""
Benchmark Scraper

This module parses benchmark log files, aggregates test results,
and generates performance comparison charts and an HTML report.
"""

import os
import re
from collections import defaultdict
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def parse_log_files():
    """
    Parse log files to extract test data, system information, and kernel versions.

    Returns:
        tuple: (test_data, kernel_info, kernel_versions)
    """
    data = defaultdict(list)
    info = defaultdict(dict)
    versions = defaultdict(dict)

    # Pre-compile regex patterns
    kernel_version_pattern = re.compile(r'Kernel: (\S+)')
    system_info_pattern = re.compile(r'System:(.*?)$', re.DOTALL)
    test_results_pattern = re.compile(
        r'(stress-ng cpu-cache-mem|y-cruncher pi 1b|perf sched msg fork thread|'
        r'perf memcpy|namd 92K atoms|calculating prime numbers|argon2 hashing|'
        r'ffmpeg compilation|xz compression|kernel defconfig|blender render|'
        r'x265 encoding|Total time \(s\)|Total score): (\d+\.\d+)'
    )

    for filename in os.listdir('.'):
        if filename.endswith('.log') and filename.startswith('benchie_'):
            with open(filename, 'r', encoding='utf-8') as f:
                data_text = f.read()

            kernel_version_match = kernel_version_pattern.search(data_text)
            if kernel_version_match:
                kernel_version = kernel_version_match.group(1)
            else:
                print(f"Warning: Could not extract kernel version from file: {filename}")
                continue

            system_info_match = system_info_pattern.search(data_text)
            if system_info_match:
                system_info = system_info_match.group(1).strip()
            else:
                print(f"Warning: Could not extract system information from file: {filename}")
                continue

            for match in test_results_pattern.finditer(data_text):
                test_name = match.group(1)
                test_time = float(match.group(2))
                data[(kernel_version, test_name)].append(test_time)
                versions[kernel_version].setdefault(test_name, []).append(test_time)
                info[kernel_version] = system_info

    return data, info, versions


def aggregate_test_results(data):
    """
    Aggregate test results by calculating the mean.

    Args:
        data (dict): Dictionary of test results.

    Returns:
        dict: Aggregated data with mean values.
    """
    aggregated_data = {}
    for key, values in data.items():
        aggregated_data[key] = np.mean(values)
    return aggregated_data


def plot_horizontal_bar_chart_with_annotations(avg_times_list, mode, kernel_ver_list):
    """
    Plot horizontal bar chart with annotations.

    Args:
        avg_times_list (list): List of dictionaries containing average times.
        mode (str): Mode string for the title and filename.
        kernel_ver_list (list): List of kernel versions.
    """
    test_names_list = list(avg_times_list[0].keys())
    test_names_list.reverse()
    num_kernel_versions = len(avg_times_list)

    fig, axes = plt.subplots(num_kernel_versions, 1, figsize=(12, num_kernel_versions * 4))
    # Suppress unused variable warning if single axis
    if num_kernel_versions == 1:
        pass  # axes is just an ax object

    # Reverse the order of avg_times_list and kernel_ver_list
    avg_times_list = avg_times_list[::-1]
    kernel_ver_list = kernel_ver_list[::-1]

    for i, avg_times in enumerate(avg_times_list):
        kernel_version = kernel_ver_list[i]
        ax = axes[i] if num_kernel_versions > 1 else axes
        values = list(avg_times.values())[::-1]
        ax.barh(test_names_list, values, color='skyblue')
        for j, value in enumerate(values):
            ax.text(value, j, f'{value:.2f}', ha='left', va='center')
        ax.set_xlabel('Average Time (s), Less is better')
        ax.set_ylabel('Mini-Benchmarker')
        ax.set_title(f'Test Performance - Kernel Version: {kernel_version} ({mode} mode)')
        ax.grid(axis='x')

    plt.tight_layout()
    plt.savefig(f'average_performance_comparison_horizontal_{mode}.png')
    plt.close(fig)


# Define a color palette
COLORS = list(mcolors.TABLEAU_COLORS.keys())


def plot_kernel_version_comparison(avg_times_list, mode, kernel_ver_list):
    """
    Plot performance comparison between different kernel versions.

    Args:
        avg_times_list (list): List of dictionaries containing average times.
        mode (str): Mode string for the title and filename.
        kernel_ver_list (list): List of kernel versions.
    """
    test_names_list = list(avg_times_list[0].keys())
    test_names_list.reverse()
    num_tests = len(test_names_list)
    num_kernel_versions = len(kernel_ver_list)

    # Dynamically adjust the figure height based on the number of tests and kernel versions
    base_height_per_test = 0.7  # Base height per test
    additional_height_per_kernel = 1.8  # Additional height per kernel version
    fig_height = (
        base_height_per_test * num_tests +
        additional_height_per_kernel * num_kernel_versions
    )

    fig_width = 12  # Keep the width fixed
    fig, ax = plt.subplots(figsize=(fig_width, fig_height))

    # Calculate the height of each bar
    # Ensure the bars fit within the allocated space for each test
    bar_height = 0.8 / num_kernel_versions

    # Adjust font size based on the number of kernel versions
    font_size = max(6, 16 - num_kernel_versions * 0.5)  # Minimum font size of 6

    for i, avg_times in enumerate(avg_times_list):
        kernel_version = kernel_ver_list[i]
        values = list(avg_times.values())[::-1]
        color = COLORS[i % len(COLORS)]  # Use modulo to loop through the color palette
        ax.barh(
            np.arange(num_tests) + i * bar_height,
            values,
            height=bar_height,
            label=kernel_version,
            color=color
        )
        for j, value in enumerate(values):
            ax.text(
                value,
                j + i * bar_height,
                f'{value:.2f}',
                fontsize=font_size,
                ha='left',
                va='center',
                color='black'
            )

    ax.set_yticks(np.arange(num_tests) + bar_height * (num_kernel_versions - 1) / 2)
    ax.set_yticklabels(test_names_list)
    ax.set_xlabel('Average Time (s). Less is better')
    ax.set_ylabel('Mini-Benchmarker')
    ax.set_title(
        f'Test Performance Comparison Between Different Kernel Versions ({mode} mode)'
    )

    # Reverse the order of the legend entries
    handles, labels = ax.get_legend_handles_labels()
    ax.legend(handles[::-1], labels[::-1], loc='lower right')
    ax.grid(axis='x')

    plt.tight_layout()
    plt.savefig(f'kernel_version_comparison_{mode}.png')
    plt.close(fig)


if __name__ == "__main__":
    # Extract test data, system information, and kernel versions from .log files
    test_data, kernel_info, kernel_versions = parse_log_files()

    # Check if logs were found
    if test_data:
        # Get sorted kernel versions
        sorted_kernel_versions = sorted(kernel_versions.keys())

        # Get kernel versions list
        kernel_versions_list = list(sorted_kernel_versions)

        # Calculate average test times for each kernel version
        average_times = [
            aggregate_test_results(kernel_versions[kv])
            for kv in sorted_kernel_versions
        ]

        # Plot horizontal bar chart with annotations
        plot_horizontal_bar_chart_with_annotations(
            average_times, 'All', kernel_versions_list
        )

        # Plot performance comparison between different kernel versions
        plot_kernel_version_comparison(
            average_times, 'All', kernel_versions_list
        )

        # Generate HTML page
        HTML_CONTENT = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Test Performance</title>
    </head>
    <body>
        <h1>Test Performance</h1>
    """

        # Include charts for comparison of different kernel version performance
        # based on average calculations
        HTML_CONTENT += """
    <h2>Average Test Performance Comparison</h2>
    <img src="average_performance_comparison_horizontal_All.png" alt="Average Test Performance Comparison - All Kernels" style="max-width: 100%; height: auto;">
    """

        # Include charts for comparison of performance between different kernel versions
        HTML_CONTENT += """
    <h2>Performance Comparison Between Different Kernel Versions</h2>
    <img src="kernel_version_comparison_All.png" alt="Performance Comparison Between Different Kernel Versions - All Kernels" style="max-width: 100%; height: auto;">
    """

        HTML_CONTENT += """
    </body>
    </html>
    """

        # Write HTML content to a file
        with open('test_performance.html', 'w', encoding='utf-8') as html_file:
            html_file.write(HTML_CONTENT)

        print("HTML page generated successfully!")
    else:
        print("No logs found. HTML page not generated.")
