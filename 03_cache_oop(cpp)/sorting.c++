//selection sort
//Selection Sort repeatedly finds the smallest element from an unsorted part of the array and swaps it to the front.
#include <iostream>
#include <vector>
using namespace std;

void selectionSort(vector<int>& arr) {
    int n = arr.size();
    for(int i = 0; i < n - i; i++) {
        int min_index = i;
        for(int j = i + 1; j < n; j++) {
            if(arr[j] < arr[min_index]) min_index = j; 
        }
        swap(arr[i], arr[min_index]);
    }

}

//QuickSort (Divide and Conquer)
//Choose a Pivot (usually last, first, or random element).
// 2.	Partition the array around the pivot:
// •	Elements smaller than pivot go to the left.
// •	Elements greater than pivot go to the right.
// 3.	Recursively sort left and right subarrays.
#include <iostream>
#include <vector>
using namespace std;

int partition(vector<int>& arr, int low, int high) {
    int pivot = arr[high];  // Pivot is last element
    int i = low - 1;  

    for (int j = low; j < high; j++) {
        if (arr[j] <= pivot) {
            i++;
            swap(arr[i], arr[j]);
        }
    }
    swap(arr[i + 1], arr[high]);
    return i + 1;
}

void quickSort(vector<int>& arr, int low, int high) {
    if (low < high) {
        int pi = partition(arr, low, high);
        quickSort(arr, low, pi - 1);
        quickSort(arr, pi + 1, high);
    }
}

int main() {
    vector<int> arr = {10, 7, 8, 9, 1, 5};
    quickSort(arr, 0, arr.size() - 1);
    for (int num : arr) cout << num << " ";
    return 0;
}
//Best Case (random data):	O(n log n)
//Average Case:	O(n log n)
//Worst Case (already sorted, bad pivot choice):O(n²)

//merge sort
#include <iostream>
#include <vector>
using namespace std;

void merge(vector<int>& arr, int left, int mid, int right) {
    int n1 = mid - left + 1;
    int n2 = right - mid;
    vector<int> L(n1), R(n2);

    for (int i = 0; i < n1; i++) L[i] = arr[left + i];
    for (int i = 0; i < n2; i++) R[i] = arr[mid + 1 + i];

    int i = 0, j = 0, k = left;
    while (i < n1 && j < n2) {
        if (L[i] <= R[j]) arr[k++] = L[i++];
        else arr[k++] = R[j++];
    }
    while (i < n1) arr[k++] = L[i++];
    while (j < n2) arr[k++] = R[j++];
}

void mergeSort(vector<int>& arr, int left, int right) {
    if (left < right) {
        int mid = left + (right - left) / 2;
        mergeSort(arr, left, mid);
        mergeSort(arr, mid + 1, right);
        merge(arr, left, mid, right);
    }
}

int main() {
    vector<int> arr = {38, 27, 43, 3, 9, 82, 10};
    mergeSort(arr, 0, arr.size() - 1);
    for (int num : arr) cout << num << " ";
    return 0;
}