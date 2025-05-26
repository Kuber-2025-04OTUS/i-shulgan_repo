/*
Copyright 2025 Igor Shulgan.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package controller

import (
	"context"

	otusv1 "github.com/Kuber-2025-04OTUS/i-shulgan_repo/api/v1"
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	apierrors "k8s.io/apimachinery/pkg/api/errors"
	resource "k8s.io/apimachinery/pkg/api/resource"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/client-go/tools/record"
	"k8s.io/utils/pointer"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

// MySQLReconciler reconciles a MySQL object
type MySQLReconciler struct {
	client.Client
	Scheme   *runtime.Scheme
	Recorder record.EventRecorder
}

//+kubebuilder:rbac:groups=otus.homework,resources=mysqls,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=otus.homework,resources=mysqls/status,verbs=get;update;patch
//+kubebuilder:rbac:groups=otus.homework,resources=mysqls/finalizers,verbs=update

// Reconcile is part of the main kubernetes reconciliation loop which aims to
// move the current state of the cluster closer to the desired state.
// TODO(user): Modify the Reconcile function to compare the state specified by
// the MySQL object against the actual cluster state, and then
// perform operations to make the cluster state reflect the state specified by
// the user.
//
// For more details, check Reconcile and its Result here:
// - https://pkg.go.dev/sigs.k8s.io/controller-runtime@v0.17.3/pkg/reconcile
func (r *MySQLReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	log := log.FromContext(ctx)

	var mysql otusv1.MySQL
	if err := r.Get(ctx, req.NamespacedName, &mysql); err != nil {
		if apierrors.IsNotFound(err) {
			return ctrl.Result{}, nil
		}
		log.Error(err, "Не удалось получить объект MySQL")
		return ctrl.Result{}, err
	}

	finalizerName := "mysql.otus.homework/finalizer"

	if mysql.ObjectMeta.DeletionTimestamp.IsZero() {

		if !containsString(mysql.GetFinalizers(), finalizerName) {
			mysql.SetFinalizers(append(mysql.GetFinalizers(), finalizerName))
			if err := r.Update(ctx, &mysql); err != nil {
				return ctrl.Result{}, err
			}
		}
	} else {
		if containsString(mysql.GetFinalizers(), finalizerName) {
			r.Recorder.Event(&mysql, corev1.EventTypeNormal, "Finalizer", "Starting finalization")
			pvcName := mysql.Name + "-pvc"
			_ = r.Delete(ctx, &corev1.PersistentVolumeClaim{
				ObjectMeta: metav1.ObjectMeta{Name: pvcName, Namespace: mysql.Namespace},
			})

			_ = r.Delete(ctx, &appsv1.Deployment{
				ObjectMeta: metav1.ObjectMeta{Name: mysql.Name, Namespace: mysql.Namespace},
			})
			_ = r.Delete(ctx, &corev1.Service{
				ObjectMeta: metav1.ObjectMeta{Name: mysql.Name, Namespace: mysql.Namespace},
			})

			mysql.SetFinalizers(removeString(mysql.GetFinalizers(), finalizerName))
			if err := r.Update(ctx, &mysql); err != nil {
				r.Recorder.Event(&mysql, corev1.EventTypeWarning, "FinalizeFailed", err.Error())
				return ctrl.Result{}, err
			}
			r.Recorder.Event(&mysql, corev1.EventTypeNormal, "Finalized", "Finalizer removed, deletion complete")
		}
		return ctrl.Result{}, nil
	}

	pvc := &corev1.PersistentVolumeClaim{
		ObjectMeta: metav1.ObjectMeta{
			Name:      mysql.Name + "-pvc",
			Namespace: mysql.Namespace,
		},
		Spec: corev1.PersistentVolumeClaimSpec{
			AccessModes: []corev1.PersistentVolumeAccessMode{corev1.ReadWriteOnce},
			Resources: corev1.VolumeResourceRequirements{
				Requests: corev1.ResourceList{
					corev1.ResourceStorage: resource.MustParse(mysql.Spec.StorageSize),
				},
			},
		},
	}
	r.Recorder.Event(&mysql, corev1.EventTypeNormal, "Create", "PVC created")
	if err := ctrl.SetControllerReference(&mysql, pvc, r.Scheme); err != nil {
		return ctrl.Result{}, err
	}
	var existingPVC corev1.PersistentVolumeClaim
	err := r.Get(ctx, client.ObjectKey{Name: pvc.Name, Namespace: pvc.Namespace}, &existingPVC)
	if apierrors.IsNotFound(err) {
		if err := r.Create(ctx, pvc); err != nil {
			return ctrl.Result{}, err
		}
	}

	deploy := &appsv1.Deployment{
		ObjectMeta: metav1.ObjectMeta{
			Name:      mysql.Name,
			Namespace: mysql.Namespace,
		},
		Spec: appsv1.DeploymentSpec{
			Replicas: pointer.Int32(1),
			Selector: &metav1.LabelSelector{
				MatchLabels: map[string]string{"app": mysql.Name},
			},
			Template: corev1.PodTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{
					Labels: map[string]string{"app": mysql.Name},
				},
				Spec: corev1.PodSpec{
					Containers: []corev1.Container{{
						Name:  "mysql",
						Image: mysql.Spec.Image,
						Ports: []corev1.ContainerPort{{ContainerPort: 3306}},
						Env: []corev1.EnvVar{
							{
								Name:  "MYSQL_ROOT_PASSWORD",
								Value: "password",
							},
						},
						VolumeMounts: []corev1.VolumeMount{{
							Name:      "data",
							MountPath: "/var/lib/mysql",
						}},
					}},
					Volumes: []corev1.Volume{{
						Name: "data",
						VolumeSource: corev1.VolumeSource{
							PersistentVolumeClaim: &corev1.PersistentVolumeClaimVolumeSource{
								ClaimName: pvc.Name,
							},
						},
					}},
				},
			},
		},
	}
	r.Recorder.Event(&mysql, corev1.EventTypeNormal, "Create", "Deployment created")
	if err := ctrl.SetControllerReference(&mysql, deploy, r.Scheme); err != nil {
		return ctrl.Result{}, err
	}
	var existingDeploy appsv1.Deployment
	err = r.Get(ctx, client.ObjectKey{Name: deploy.Name, Namespace: deploy.Namespace}, &existingDeploy)
	if apierrors.IsNotFound(err) {
		if err := r.Create(ctx, deploy); err != nil {
			return ctrl.Result{}, err
		}
	}

	svc := &corev1.Service{
		ObjectMeta: metav1.ObjectMeta{
			Name:      mysql.Name,
			Namespace: mysql.Namespace,
		},
		Spec: corev1.ServiceSpec{
			Selector: map[string]string{"app": mysql.Name},
			Ports: []corev1.ServicePort{{
				Port:     3306,
				Protocol: corev1.ProtocolTCP,
			}},
			Type: corev1.ServiceTypeClusterIP,
		},
	}
	r.Recorder.Event(&mysql, corev1.EventTypeNormal, "Create", "Service created")
	if err := ctrl.SetControllerReference(&mysql, svc, r.Scheme); err != nil {
		return ctrl.Result{}, err
	}
	var existingSvc corev1.Service
	err = r.Get(ctx, client.ObjectKey{Name: svc.Name, Namespace: svc.Namespace}, &existingSvc)
	if apierrors.IsNotFound(err) {
		if err := r.Create(ctx, svc); err != nil {
			return ctrl.Result{}, err
		}
	}

	return ctrl.Result{}, nil
}

// SetupWithManager sets up the controller with the Manager.
func (r *MySQLReconciler) SetupWithManager(mgr ctrl.Manager) error {
	r.Recorder = mgr.GetEventRecorderFor("mysql-controller")
	return ctrl.NewControllerManagedBy(mgr).
		For(&otusv1.MySQL{}).
		Complete(r)
}

func containsString(slice []string, s string) bool {
	for _, item := range slice {
		if item == s {
			return true
		}
	}
	return false
}

func removeString(slice []string, s string) []string {
	var result []string
	for _, item := range slice {
		if item != s {
			result = append(result, item)
		}
	}
	return result
}
