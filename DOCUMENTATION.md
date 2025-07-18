# توثيق مشروع الوسيط - نظام نقطة بيع للمطاعم

## نظرة عامة

هذا المشروع عبارة عن نظام نقطة بيع متكامل لمطعم وجبات سريعة مبني باستخدام Flutter. المشروع مصمم للعمل على نظام ويندوز ويدعم طابعات الكاشير. يتميز بواجهة مستخدم بسيطة وسهلة الاستخدام باللغة العربية، وقاعدة بيانات مدمجة SQLite لتخزين البيانات.

## هيكل المشروع

### 1. نماذج البيانات (Models)

#### Product (المنتج)
```dart
// lib/models/product.dart
```
- يمثل منتجًا في المطعم (وجبة، مشروب، إلخ)
- الخصائص:
  - `id`: معرف فريد للمنتج
  - `name`: اسم المنتج
  - `price`: سعر المنتج
  - `category`: فئة المنتج (برجر، مشروبات، إلخ)
  - `isAvailable`: حالة توفر المنتج

#### CartItem (عنصر السلة)
```dart
// lib/models/cart_item.dart
```
- يمثل منتجًا مضافًا إلى سلة المشتريات
- الخصائص:
  - `product`: المنتج المضاف
  - `quantity`: الكمية المطلوبة
  - `notes`: ملاحظات إضافية (مثل: بدون بصل، إلخ)

#### Order (الطلب)
```dart
// lib/models/order.dart
```
- يمثل طلبًا مكتملًا
- الخصائص:
  - `id`: معرف فريد للطلب
  - `items`: قائمة المنتجات في الطلب
  - `dateTime`: تاريخ ووقت الطلب
  - `totalAmount`: المبلغ الإجمالي للطلب
  - `orderType`: نوع الطلب (للمطعم، للتوصيل، للاستلام)
  - `customerName`: اسم العميل (اختياري)
  - `customerPhone`: رقم هاتف العميل (اختياري)
  - `customerAddress`: عنوان العميل (اختياري)
  - `paymentMethod`: طريقة الدفع (نقدي، بطاقة)

### 2. مزودي البيانات (Providers)

#### ProductProvider
```dart
// lib/providers/product_provider.dart
```
- يدير قائمة المنتجات وعمليات CRUD عليها
- الوظائف الرئيسية:
  - `fetchProducts()`: جلب المنتجات من قاعدة البيانات
  - `addProduct()`: إضافة منتج جديد
  - `updateProduct()`: تحديث منتج موجود
  - `deleteProduct()`: حذف منتج
  - `getProductsByCategory()`: الحصول على المنتجات حسب الفئة

#### CartProvider
```dart
// lib/providers/cart_provider.dart
```
- يدير سلة المشتريات الحالية
- الوظائف الرئيسية:
  - `addItem()`: إضافة منتج إلى السلة
  - `removeItem()`: إزالة منتج من السلة
  - `updateItemQuantity()`: تحديث كمية منتج في السلة
  - `updateItemNotes()`: تحديث ملاحظات منتج في السلة
  - `clear()`: تفريغ السلة

#### OrderProvider
```dart
// lib/providers/order_provider.dart
```
- يدير الطلبات المكتملة
- الوظائف الرئيسية:
  - `fetchOrders()`: جلب الطلبات من قاعدة البيانات
  - `getOrderById()`: الحصول على طلب بواسطة المعرف
  - `addOrder()`: إضافة طلب جديد
  - `getTodayOrders()`: الحصول على طلبات اليوم
  - `getOrdersByDateRange()`: الحصول على الطلبات في نطاق تاريخ معين
  - `calculateTotalSales()`: حساب إجمالي المبيعات لقائمة من الطلبات

### 3. الخدمات (Services)

#### DatabaseService
```dart
// lib/services/database_service.dart
```
- يدير التفاعل مع قاعدة بيانات SQLite
- الوظائف الرئيسية:
  - إنشاء وتهيئة قاعدة البيانات
  - عمليات CRUD على المنتجات
  - عمليات CRUD على الطلبات
  - استعلامات مختلفة على البيانات

#### PrintService
```dart
// lib/services/print_service.dart
```
- يدير طباعة الفواتير
- الوظائف الرئيسية:
  - `printReceipt()`: إنشاء وطباعة فاتورة لطلب معين

### 4. الشاشات الرئيسية (Screens)

#### HomeScreen
```dart
// lib/screens/home_screen.dart
```
- الشاشة الرئيسية للتطبيق
- تعرض المنتجات مقسمة حسب الفئات
- تتيح إضافة المنتجات إلى السلة
- توفر الوصول إلى الشاشات الأخرى (إدارة المنتجات، الطلبات، التقارير)

#### ProductManagementScreen
```dart
// lib/screens/product_management_screen.dart
```
- شاشة إدارة المنتجات
- تتيح إضافة وتعديل وحذف المنتجات
- تعرض قائمة بجميع المنتجات المتاحة

#### OrdersScreen
```dart
// lib/screens/orders_screen.dart
```
- شاشة عرض الطلبات السابقة
- تتيح عرض تفاصيل الطلبات
- تتيح طباعة فواتير للطلبات السابقة

#### ReportsScreen
```dart
// lib/screens/reports_screen.dart
```
- شاشة عرض تقارير المبيعات
- تتيح عرض تقارير يومية، أسبوعية، شهرية، أو مخصصة
- تعرض إحصائيات مثل إجمالي المبيعات، عدد الطلبات، المنتجات الأكثر مبيعًا، إلخ

### 5. الواجهات (Widgets)

#### ProductGrid
```dart
// lib/widgets/product_grid.dart
```
- يعرض المنتجات في شبكة
- يتيح تصفية المنتجات حسب الفئة
- يتيح إضافة المنتجات إلى السلة مع تحديد الكمية والملاحظات

#### CartDrawer
```dart
// lib/widgets/cart_drawer.dart
```
- يعرض سلة المشتريات الحالية
- يتيح تعديل الكميات وإزالة المنتجات
- يتيح إتمام الطلب مع تحديد نوع الطلب وطريقة الدفع وبيانات العميل

## قاعدة البيانات

يستخدم المشروع قاعدة بيانات SQLite المدمجة مع الجداول التالية:

### جدول المنتجات (products)
- `id`: معرف فريد للمنتج (INTEGER PRIMARY KEY)
- `name`: اسم المنتج (TEXT)
- `price`: سعر المنتج (REAL)
- `category`: فئة المنتج (TEXT)
- `isAvailable`: حالة توفر المنتج (INTEGER)

### جدول الطلبات (orders)
- `id`: معرف فريد للطلب (INTEGER PRIMARY KEY)
- `dateTime`: تاريخ ووقت الطلب (TEXT)
- `totalAmount`: المبلغ الإجمالي للطلب (REAL)
- `orderType`: نوع الطلب (TEXT)
- `customerName`: اسم العميل (TEXT)
- `customerPhone`: رقم هاتف العميل (TEXT)
- `customerAddress`: عنوان العميل (TEXT)
- `paymentMethod`: طريقة الدفع (TEXT)

### جدول عناصر الطلب (order_items)
- `id`: معرف فريد لعنصر الطلب (INTEGER PRIMARY KEY)
- `orderId`: معرف الطلب (INTEGER)
- `productId`: معرف المنتج (INTEGER)
- `quantity`: الكمية (INTEGER)
- `notes`: ملاحظات (TEXT)

## تدفق العمل في التطبيق

### 1. إدارة المنتجات
- إضافة منتجات جديدة مع تحديد الاسم والسعر والفئة
- تعديل المنتجات الموجودة
- تحديد توفر/عدم توفر المنتجات
- حذف المنتجات

### 2. إنشاء طلب جديد
- اختيار المنتجات من الشاشة الرئيسية
- تحديد الكمية والملاحظات لكل منتج
- عرض السلة ومراجعة المنتجات المضافة
- تحديد نوع الطلب (للمطعم، للتوصيل، للاستلام)
- تحديد طريقة الدفع (نقدي، بطاقة)
- إدخال بيانات العميل إذا كان الطلب للتوصيل أو للاستلام
- تأكيد الطلب وحفظه في قاعدة البيانات
- طباعة الفاتورة

### 3. إدارة الطلبات السابقة
- عرض قائمة بالطلبات السابقة
- عرض تفاصيل أي طلب
- إعادة طباعة الفاتورة لأي طلب سابق

### 4. التقارير
- عرض تقارير المبيعات اليومية
- عرض تقارير المبيعات الأسبوعية
- عرض تقارير المبيعات الشهرية
- عرض تقارير مخصصة لفترة زمنية محددة
- عرض المنتجات الأكثر مبيعًا
- عرض المبيعات حسب الفئة

## المتطلبات التقنية

- **Flutter SDK**: لتطوير التطبيق
- **SQLite**: لقاعدة البيانات المدمجة
- **Provider**: لإدارة حالة التطبيق
- **PDF & Printing**: لإنشاء وطباعة الفواتير
- **Intl**: للتعامل مع التواريخ والأرقام
- **Path Provider**: للوصول إلى مسارات النظام

## كيفية تشغيل المشروع

1. تثبيت Flutter SDK
2. تثبيت التبعيات باستخدام الأمر:
   ```
   flutter pub get
   ```
3. تشغيل التطبيق على نظام ويندوز:
   ```
   flutter run -d windows
   ```

## توسيعات مستقبلية محتملة

1. **إدارة المخزون**: تتبع كميات المكونات واستهلاكها
2. **إدارة الموظفين**: تسجيل دخول للموظفين مع صلاحيات مختلفة
3. **برنامج ولاء**: نظام نقاط للعملاء المتكررين
4. **تكامل مع أنظمة خارجية**: مثل أنظمة المحاسبة أو منصات التوصيل
5. **واجهة ويب للإدارة**: للوصول إلى التقارير والإعدادات عن بعد
6. **نسخ احتياطي سحابي**: لحماية البيانات
7. **دعم العملات المتعددة**: للاستخدام في بلدان مختلفة
8. **دعم الضرائب**: إضافة حساب الضرائب المختلفة

## ملاحظات هامة

- التطبيق مصمم للعمل على نظام ويندوز
- يدعم التطبيق اللغة العربية بشكل كامل
- قاعدة البيانات مدمجة ولا تحتاج إلى خادم خارجي
- يدعم التطبيق طباعة الفواتير على طابعات الكاشير الحرارية
- التطبيق مخصص للاستخدام الشخصي

## الدعم والمساعدة

إذا واجهتك أي مشكلة أو كنت بحاجة إلى مساعدة، يمكنك:
- مراجعة هذا التوثيق
- فحص كود المصدر والتعليقات
- البحث عن المشكلة في مجتمع Flutter

---

تم إنشاء هذا المشروع كنظام نقطة بيع بسيط وسهل الاستخدام للمطاعم الصغيرة. يمكن تخصيصه وتوسيعه حسب احتياجاتك الخاصة.