def remove_duplicates(input_string: str) -> str:
    # dict.fromkeys() preserves insertion order and removes duplicates.
    # This also side-steps the static analyzer bug in the IDE.
    return "".join(dict.fromkeys(input_string))

if __name__ == "__main__":
    test_cases = ["hello", "programming", "aaabbbccc", "abc", "mississippi"]
    for case in test_cases:
        print(f'"{case}" becomes "{remove_duplicates(case)}"')
