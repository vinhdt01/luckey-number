# Sử dụng Node.js image chính thức
FROM node:20-alpine

# Tạo thư mục làm việc
WORKDIR /app

# Sao chép package.json và yarn.lock
COPY package*.json yarn.lock* ./

# Cài đặt dependencies
RUN yarn install

# Sao chép source code
COPY . .

# Build ứng dụng
RUN yarn build

# Expose port
EXPOSE 3000

# Chạy ứng dụng
CMD ["node", "dist/main.js"]