import requests

def predict_customer_churn(server_url="http://127.0.0.1:5000", data=None):
    if data is None:
        data = {
            "Age": 30,
            "IsFemale": 1,
            "IsAppUser": 1,
            "VehicleOwned": 1,
            "AmenityCount": 3,
            "ActualStayDays": 15,
            "ContractDays": 20,
            "StayRatio": 0.75,
            "Gender": 0,
            "AppRegistered": 1,
            "TempResidenceStatus": 0,
            "VehicleType": 2,
            "ContractStatus": 1,
            "RoomGender": 0,
            "RoomType": 2,
            "AgeGroup": 1
        }

    try:
        url = f"{server_url}/predict"
        response = requests.post(url, json=data)
        response.raise_for_status()
        result = response.json()
        print("\n✅ Kết quả dự đoán:")
        print(f"- Rời đi: {'Có' if result['prediction'] == 1 else 'Không'}")
        print(f"- Xác suất: {round(result['probability']*100, 2)}%")
    except requests.exceptions.RequestException as e:
        print("❌ Lỗi khi gửi yêu cầu dự đoán:", e)

def test_room_recommendation(customer_id=0, top_n=3, server_url="http://127.0.0.1:5000"):
    try:
        url = f"{server_url}/recommend/{customer_id}?top_n={top_n}"
        response = requests.get(url)
        response.raise_for_status()
        rooms = response.json()
        print(f"\n✅ Top {top_n} phòng được gợi ý cho khách {customer_id}:")
        for i, room in enumerate(rooms, start=1):
            print(f"{i}. RoomID: {room['RoomID']}, Similarity: {round(room['similarity'], 3)}")
    except requests.exceptions.RequestException as e:
        print("❌ Lỗi khi gửi yêu cầu gợi ý phòng:", e)

def main():
    print("=== CHỌN CHỨC NĂNG ===")
    print("1. Dự đoán khách rời đi")
    print("2. Gợi ý phòng")
    choice = input("Nhập lựa chọn (1 hoặc 2): ").strip()

    if choice == '1':
        # Bạn có thể sửa data ở đây nếu muốn thử dữ liệu khác
        predict_customer_churn()
    elif choice == '2':
        try:
            customer_id = int(input("Nhập customer_id (số nguyên): ").strip())
        except ValueError:
            customer_id = 0
        try:
            top_n = int(input("Nhập số phòng muốn gợi ý (top_n): ").strip())
        except ValueError:
            top_n = 3
        test_room_recommendation(customer_id=customer_id, top_n=top_n)
    else:
        print("Lựa chọn không hợp lệ. Vui lòng chạy lại và nhập 1 hoặc 2.")

if __name__ == "__main__":
    main()
