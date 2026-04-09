def convert_minutes(minutes: int) -> str:
    hours = minutes // 60
    remaining_minutes = minutes % 60
    
    if hours > 0 and remaining_minutes > 0:
        return f"{hours} hrs {remaining_minutes} minutes"
    elif hours > 0:
        return f"{hours} hrs"
    else:
        return f"{remaining_minutes} minutes"

if __name__ == "__main__":
    test_cases = [130, 110, 60, 45]
    for case in test_cases:
        print(f"{case} becomes \"{convert_minutes(case)}\"")
