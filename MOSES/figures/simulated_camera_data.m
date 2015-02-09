row_data = 0:2047;
row_data_fi = fi(row_data,0,14);
for k = 1:1024
image_data(k,:) = row_data_fi;
end
image(image_data);colormap(gray)
image_data
image(uint16(image_data));colormap(gray)
imagesc(uint16(image_data));colormap(gray)
plot(image_data(1,:))