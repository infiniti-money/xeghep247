export const roleActions = {
  "Hành khách": [{label:"Tìm xe ghép",view:"home",mode:"passenger"},{label:"Tìm ghế du lịch",view:"home",mode:"tourism"},{label:"Bản nháp của tôi",view:"activity"}],
  "Chủ hàng": [{label:"Tìm xe gửi hàng",view:"home",mode:"cargo"},{label:"Bản nháp gửi hàng",view:"activity"}],
  "Tài xế": [{label:"Đăng chuyến chở khách",view:"driver",mode:"passenger"},{label:"Đăng chuyến chở hàng",view:"driver",mode:"cargo"},{label:"Bản nháp chuyến",view:"activity"}],
  "Nhà xe": [{label:"Đăng chuyến du lịch",view:"driver",mode:"tourism"},{label:"Đăng chuyến liên tỉnh",view:"driver",mode:"passenger"},{label:"Bản nháp chuyến",view:"activity"}],
  "Quản trị": []
};
export function actionsForRole(role) {
  return Object.hasOwn(roleActions, role) ? roleActions[role] : [];
}
