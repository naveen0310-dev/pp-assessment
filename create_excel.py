import pandas as pd
import openpyxl
import os

folder_path = r'c:\Users\nchin\OneDrive\Desktop\pp\Spreadsheets'
os.makedirs(folder_path, exist_ok=True)
excel_path = os.path.join(folder_path, 'Ticket_Analysis.xlsx')

# 1. Prepare raw data
ticket_data = [
    {"ticket_id": "isu-sjd-457", "created_at": "2021-08-19 16:45:43", "closed_at": "2021-08-22 12:33:32", "outlet_id": "wrqy-juv-978", "cms_id": "vew-iuvd-12"},
    {"ticket_id": "qer-fal-092", "created_at": "2021-08-21 11:09:22", "closed_at": "2021-08-21 17:13:45", "outlet_id": "8woh-k3u-23b", "cms_id": "some-id-1"}
]

feedbacks_data = [
    {"cms_id": "vew-iuvd-12", "feedback_at": "2021-08-21 13:26:48", "feedback_rating": 3, "ticket_created_at": ""}
]

df_ticket = pd.DataFrame(ticket_data)
# Let Pandas parse datetimes so Excel natively visualizes them as dates
df_ticket["created_at"] = pd.to_datetime(df_ticket["created_at"])
df_ticket["closed_at"] = pd.to_datetime(df_ticket["closed_at"])

df_feedbacks = pd.DataFrame(feedbacks_data)
df_feedbacks["feedback_at"] = pd.to_datetime(df_feedbacks["feedback_at"])

# Initialize writer
writer = pd.ExcelWriter(excel_path, engine='openpyxl')
df_ticket.to_excel(writer, sheet_name='ticket', index=False)
df_feedbacks.to_excel(writer, sheet_name='feedbacks', index=False)

workbook = writer.book
ticket_sheet = workbook['ticket']
feedbacks_sheet = workbook['feedbacks']

# Add Helper Columns to 'ticket' sheet for Q2
# Column F: Same Day?
# Column G: Same Hour?
ticket_sheet['F1'] = "Same Day?"
ticket_sheet['G1'] = "Same Hour?"

for row in range(2, len(ticket_data) + 2):
    # Same day check formula
    ticket_sheet[f'F{row}'] = f'=INT(B{row})=INT(C{row})'
    # Same hour check formula 
    ticket_sheet[f'G{row}'] = f'=AND(INT(B{row})=INT(C{row}), HOUR(B{row})=HOUR(C{row}))'

# Answer to Q1: Populating the created_at dates using INDEX+MATCH
for row in range(2, len(feedbacks_data) + 2):
    # D column receives the INDEX-MATCH formula
    feedbacks_sheet[f'D{row}'] = f'=INDEX(ticket!B:B, MATCH(A{row}, ticket!E:E, 0))'

try:
    writer.close()
    print(f"Excel file successfully created and populated at {excel_path}!")
except Exception as e:
    print(f"Error saving excel file: {e}")
