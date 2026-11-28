export function itineraryFor(id) {
 const routes = {
  T1: [{place:"Hà Nội",time:"07:00"},{place:"Hải Dương",time:"08:30"},{place:"Hạ Long",time:"10:30"}],
  T2: [{place:"Hà Nội",time:"08:30"},{place:"Phủ Lý",time:"09:45"},{place:"Ninh Bình",time:"11:00"}]
 };
 return Object.hasOwn(routes,id) ? routes[id] : [];
}
